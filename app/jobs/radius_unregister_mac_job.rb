class RadiusUnregisterMacJob < ApplicationJob
  queue_as :default

  def perform(mac_address)
    unless mac_address =~ /\A[0-9a-f]{12}\z/
      logger.error("不正なMACアドレスです: #{mac_address}")
      return
    end

    # パスワードを削除
    Radius::Radcheck.destroy_by(username: mac_address)

    # VLANを削除
    Radius::Radreply.destroy_by(username: mac_address)

    # グループを削除
    Radius::Radusergroup.destroy_by(username: mac_address)

    logger.info("MACアドレスを削除しました。: #{mac_address} - #{vlan}")
  end
end
