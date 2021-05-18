class RadiusUserDelJob < ApplicationJob
  queue_as :default

  def perform(username)
    if username =~ /\A[0-9a-f]{12}\z/
      logger.error(t('messages.job.invalid_username') + ": #{username}")
      return
    end

    list = []
    # Auth-Typeを削除
    list += Radius::Radcheck.destroy_by(username: username)
    # VLANを削除
    list += Radius::Radreply.destroy_by(username: username)
    # グループを設定
    list += Radius::Radusergroup.destroy_by(username: username)

    logger.info(t('messages.job.radius_user_del') + ": #{username}")
  end
end
