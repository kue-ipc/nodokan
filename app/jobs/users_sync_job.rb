require 'set'

class UsersSyncJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    counter = sync_users
    logger.info("UsersSyncJob: #{counter.to_json}")
  end

  private def sync_users
    counter = {
      create: 0,
      update: 0,
      delete: 0,
      error: 0,
      skip: 0,
    }

    registerd_users = Set.new
    User.where(deleted: false).each do |user|
      if user.ldap_entry
        logger.debug("ユーザーをLDAPと同期: #{user.username}")
        user.sync_ldap!
        registerd_users << user.username
        counter[:update] += 1
      else
        logger.info("ユーザーを削除済みとマーク: #{user.username}")
        user.deleted = true
        counter[:delete] += 1
      end
      user.save!
    rescue StandardError => e
      logger.error("ユーザーのLDAP同期に失敗: #{user.username} - #{e}")
      counter[:error] += 1
    end

    Devise::LDAP::Adapter.get_login_list.each do |username|
      if registerd_users.include?(username)
        logger.debug("登録済み: #{username}")
        next
      end

      unless Devise::LDAP::Adapter.authorizable?(username)
        logger.info("登録不可: #{username}")
        counter[:skip] += 1
        next
      end

      # 削除済みユーザーも復活させる。
      user = User.find_or_initialize_by(username: username)

      unless user.sync_ldap!
        logger.warn("登録不可: #{username}")
        counter[:skip] += 1
        next
      end

      unless user.save
        logger.error("登録エラー: #{username}")
        counter[:error] += 1
        next
      end

      counter[:create] += 1
      logger.info("登録完了: #{username}")
    end
    counter
  end
end
