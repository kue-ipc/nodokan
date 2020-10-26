class LdapUserSyncJob < ApplicationJob
  queue_as :default

  def perform(*args)
    sync_users
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
          user.sync_ldap!
          counter[:sync] += 1
        else
          user.username = '#' + user.id.to_s + '#' + user.username
          user.deleted = true
          counter[:delete] += 1
        end
        user.save
      rescue StandardError => e
        logger.error("ユーザーのLDAP同期に失敗: #{user.username} - #{e}")
        counter[:error] += 1
      end

      counter
    end
end
