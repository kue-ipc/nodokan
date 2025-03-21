class RadiusMacDelJob < RadiusJob
  queue_as :default

  def perform(mac_address, vlan = nil)
    # VLANを削除
    if vlan
      Radius::Radreply.destroy_by(username: mac_address, attr: "Tunnel-Private-Group-Id", op: ":=", value: vlan.to_s)
      # replyに他のVLANが一つも登録されていない場合のみ削除
      unless Radius::Radreply.exists?(username: mac_address)
        # パスワードを削除
        Radius::Radcheck.destroy_by(username: mac_address)
        # グループを削除
        Radius::Radusergroup.destroy_by(username: mac_address)
      end
    else
      # パスワードを削除
      Radius::Radcheck.destroy_by(username: mac_address)
      # VLANを削除
      Radius::Radreply.destroy_by(username: mac_address)
      # グループを削除
      Radius::Radusergroup.destroy_by(username: mac_address)
    end
  end
end
