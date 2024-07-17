require "set"

class UsersSyncJob < ApplicationJob
  queue_as :default

  def perform(**opts)
    results = sync_users(**opts)
    counts = results.each_value.tally
    logger.info("Result: #{counts.to_json}")
    return unless counts[:error]&.positive?

    raise "error occured during users sync job: #{counts[:error]}"
  end

  private def sync_users(**opts)
    results = {}

    # DB上のユーザー確認
    results.merge!(check_db_users(**opts.slice(:stop_on_error)))

    # LDAP上のユーザー確認
    results.merge!(check_ldap_users(**opts.slice(:stop_on_error)))

    # 削除済みユーザーの削除
    results.merge!(destroy_deleted_users(**opts.slice(:stop_on_error)))

    results
  end

  # DB上のユーザー確認
  # 削除済みフラグがついたユーザーはチェックしない。
  def check_db_users(stop_on_error: false)
    User.where(deleted: false).find_each.to_h do |user|
      if user.authorizable?
        logger.debug("Update, sync LDAP: #{user.username}")
        user.sync_ldap!
        user.save!
        [user.username, :update]
      else
        logger.info("Delete, mark deleted: #{user.username}")
        user.update!(deleted: true)
        [user.username, :delete]
      end
    rescue StandardError => e
      logger.error(
        "Failed to check a db user: #{user.username} - #{e.message}")
      logger.error(e.full_message)
      raise if stop_on_error

      [user.username, :error]
    end
  end

  # LDAP上のユーザー確認
  # DB上に既に存在するユーザーは確認しない。
  # 認証できないユーザーは何もしない。
  def check_ldap_users(stop_on_error: false)
    existing_users = User.where(deleted: false).pluck(:username).to_set
    deleted_users = User.where(deleted: true).pluck(:username).to_set

    Devise::LDAP::Adapter.get_login_list
      # 既に存在するユーザーは除外
      .reject { |username| existing_users.include?(username) }
      # 認証できるユーザーのみ選択
      .select { |username| Devise::LDAP::Adapter.authorizable?(username) }
      .to_h do |username|
        if deleted_users.include?(username)
          # 削除済みユーザーの復活
          logger.info("Revive, sync LDAP and unmark deleted: #{username}")
          user = User.find_by(username: username)
          user.deleted = false
          user.sync_ldap!
          user.save!
          [username, :revive]
        else
          # 新規ユーザーの作成
          logger.info("Create: #{username}")
          user = User.new(username: username)
          user.ldap_before_save
          user.save!
          [username, :create]
        end
      rescue StandardError => e
        logger.error("Failed to create a user: #{username} - #{e.message}")
        logger.error(e.full_message)
        raise if stop_on_error

        [username, :error]
      end
  end

  def destroy_deleted_users(stop_on_error: false)
    if Settings.config.destroy_deleted_user
      User.where(deleted: true).find_each.to_h do |user|
        logger.info("Destroy: #{user.username}")
        user.nodes.find_each do |node|
          if Settings.config.destroy_nodes_of_deleted_user
            logger.debug("Destroy node: #{node.id}")
            node.destroy!
          else
            logger.debug("Disassociate node: #{node.id}")
            node.update!(user: nil)
          end
        end
        user.destroy!
        [user.username, :destroy]
      rescue StandardError => e
        logger.error("Failed to destroy a user: #{user.username} - #{e.message}")
        logger.error(e.full_message)
        raise if stop_on_error

        [user.username, :error]
      end
    elsif Settings.config.destroy_deleted_user_without_node
      User.where(deleted: true, nodes_count: 0).find_each.to_h do |user|
        logger.info("Destroy, without node: #{user.username}")
        user.destroy!
        [user.username, :destroy]
      rescue StandardError => e
        logger.error("Failed to destroy a user without node: " \
                     "#{user.username} - #{e.message}")
        logger.error(e.full_message)
        raise if stop_on_error

        [user.username, :error]
      end
    else
      {}
    end
  end
end
