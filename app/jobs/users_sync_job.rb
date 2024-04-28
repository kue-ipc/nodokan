require "set"

class UsersSyncJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    list = sync_users
    logger.info("Result: #{list.transform_values(&:size).to_json}")
    return if list[:error].empty?

    raise "error occured during users sync job: #{list[:error].size}"
  end

  private def sync_users
    list = {
      create: Set.new,
      update: Set.new,
      delete: Set.new,
      return: Set.new,
      error: Set.new,
      skip: Set.new,
    }

    # 既存ユーザーの確認
    User.where(deleted: false).find_each do |user|
      if user.authorizable?
        logger.debug("Update, sync LDAP: #{user.username}")
        user.sync_ldap!
        list[:update].add(user.username)
      else
        logger.info("Delete, mark deleted: #{user.username}")
        user.deleted = true
        list[:delete].add(user.username)
      end
      user.save!
    rescue StandardError => e
      logger.error(
        "Failed to check an existing user: #{user.username} - #{e.message}")
      logger.error(e.full_message)
      list[:error].add(user.username)
      list[:update].delete(user.username)
      list[:delete].delete(user.username)
    end

    # 新規ユーザーの確認
    Devise::LDAP::Adapter.get_login_list.each do |username|
      if list[:update].include?(username) || list[:delete].include?(username)
        next
      end

      unless Devise::LDAP::Adapter.authorizable?(username)
        # 対象外
        list[:skip].add(username)
        next
      end

      # 削除済みユーザーの復活
      if (user = User.find_by(username: username))
        logger.info("Return, sync LDAP and unmark deleted: #{username}")
        user.sync_ldap!
        user.deleted = false
        user.save!
        list[:return].add(username)
        next
      end

      # 新規ユーザー
      logger.info("Create: #{username}")
      user = User.new(username: username)
      user.ldap_before_save
      user.save!
      list[:create].add(username)
    rescue StandardError => e
      logger.error("Failed to create a user: #{username} - #{e.message}")
      logger.error(e.full_message)
      list[:error].add(username)
      list[:create].delete(username)
      list[:return].delete(username)
    end

    list
  end
end
