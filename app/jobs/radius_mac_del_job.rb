class RadiusMacDelJob < ApplicationJob
  queue_as :default

  def perform(mac_address)
    unless mac_address =~ /\A[0-9a-f]{12}\z/
      logger.error("不正なMACアドレスです: #{mac_address}")
      return
    end

    list = []
    # パスワードを削除
    list += Radius::Radcheck.destroy_by(username: mac_address)
    # VLANを削除
    list += Radius::Radreply.destroy_by(username: mac_address)
    # グループを削除
    list += Radius::Radusergroup.destroy_by(username: mac_address)

    unless list.empty?
      logger.info(t('messages.job.radius_mac_del') + ": #{mac_address}")
    end
  end
end
