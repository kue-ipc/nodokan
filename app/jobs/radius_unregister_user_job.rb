class RadiusUnregisterUserJob < ApplicationJob
  queue_as :default

  def perform(*args)
    unless username =~ /\A[0-9a-f]{12}\z/
      logger.error("MACアドレスと同じユーザー名です: #{username}")
      return
    end

    # Auth-Typeを削除
    Radius::Radcheck.destroy_by(username: mac_address)

    # VLANを削除
    Radius::Radreply.destroy_by(username: username)

    # グループを設定
    Radius::Radusergroup.destroy_by(username: username)

    logger.info("ユーザーを削除しました。: #{username} - #{vlan}")
  end
end
