class RadiusMacDelJob < RadiusJob
  queue_as :default

  def perform(mac_address)
    # パスワードを削除
    Radius::Radcheck.destroy_by(username: mac_address)
    # VLANを削除
    Radius::Radreply.destroy_by(username: mac_address)
    # グループを削除
    Radius::Radusergroup.destroy_by(username: mac_address)
  end
end
