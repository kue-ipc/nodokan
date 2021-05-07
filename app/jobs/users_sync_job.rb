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
      undelete: 0,
      delete: 0,
      error: 0,
      skip: 0,
    }

    # 既存ユーザーの確認
    registerd_users = Set.new
    User.where(deleted: false).each do |user|
      if user.authorizable?
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

    # 新規ユーザーの確認
    Devise::LDAP::Adapter.get_login_list.each do |username|
      if registerd_users.include?(username)
        logger.debug("登録済み: #{username}")
        next
      end

      unless Devise::LDAP::Adapter.authorizable?(username)
        # 対象外
        counter[:skip] += 1
        next
      end

      # 削除済みユーザーの復活
      if (user = User.find_by(username: username))
        user.sync_ldap!
        user.deleted = false
        user.save
        logger.info("再登録完了: #{username}")
        counter[:undelete] += 1
        next
      end

      # 新規ユーザー
      user = User.new(username: username)
      user.ldap_before_save

      unless user.save
        logger.error("登録エラー: #{username}")
        counter[:error] += 1
        next
      end

      logger.info("登録完了: #{username}")
      counter[:create] += 1
    rescue StandardError => e
      logger.error("ユーザーの登録に失敗: #{username} - #{e}")
      counter[:error] += 1
    end
    counter
  end
end
