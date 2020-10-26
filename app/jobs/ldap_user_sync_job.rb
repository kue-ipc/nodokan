class LdapUserSyncJob < ApplicationJob
  queue_as :default

  def perform(*args)
    counter = sync_users
    logger.info(
      "同期成功: #{counter[:sync]}、削除: #{counter[:delete]}、失敗: #{counter[:error]}")
  end

  private

    def sync_users
      counter = {
        sync: 0,
        delete: 0,
        error: 0,
      }

      User.where(deleted: false).each do |user|
        if user.ldap_entry
          logger.debug("ユーザーをLDAPと同期: #{user.username}")
          user.sync_ldap!
          counter[:sync] += 1
        else
          logger.info("ユーザーを削除済みとマーク: #{user.username}")
          user.username = '#' + user.id.to_s + '#' + user.username
          user.deleted = true
          counter[:delete] += 1
        end
        user.save!
      rescue StandardError => e
        logger.error("ユーザーのLDAP同期に失敗: #{user.username} - #{e}")
        counter[:error] += 1
      end

      counter
    end
end
