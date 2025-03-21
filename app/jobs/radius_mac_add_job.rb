class RadiusMacAddJob < RadiusJob
  queue_as :default

  def perform(mac_address, vlan)
    if mac_address !~ /\A[0-9a-f]{12}\z/
      raise "Cannot add the invalid mac address to RADIUS: #{mac_address}"
    end

    # 設定されていなければ、MACアドレスと同じにする。
    password =
      Rails.application.credentials.dig(:config, :radius_mac_password) ||
      Settings.config.radius_mac_password ||
      mac_address

    # パスワードを設定
    update_radius_user(Radius::Radcheck, mac_address,
      attr: "Cleartext-Password", op: ":=", value: password)

    # VLANを設定
    update_radius_user(Radius::Radreply, mac_address,
      attr: "Tunnel-Private-Group-Id", op: ":=", value: vlan.to_s)

    # グループを設定
    update_radius_user(Radius::Radusergroup, mac_address,
      groupname: "mac", priority: 1)

    logger.info("Added a mac address to RADIUS: #{mac_address} - #{vlan}")
  end
end
