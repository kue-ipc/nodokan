class RadiusMacAddJob < ApplicationJob
  queue_as :default

  def perform(mac_address_raw, vlan)
    raise "Cannot add a invalid mac address to RADIUS: #{mac_address_raw}" if mac_address_raw !~ /\A[0-9a-f]{12}\z/

    username = mac_address_raw

    # 設定されていなければ、usernameと同じにする。
    password =
      Rails.application.credentials.dig(:config, :radius_mac_password) ||
      Settings.config.radius_mac_password ||
      username

    # パスワードを設定
    Radius::Radcheck.transaction do
      params = {attr: "Cleartext-Password", op: ":=", value: password}
      update_radius_user(Radius::Radcheck, username: username, **params)
    end

    # VLANを設定
    Radius::Radreply.transaction do
      params = {attr: "Tunnel-Private-Group-Id", op: ":=", value: vlan.to_s}
      update_radius_user(Radius::Radreply, username: username, **params)
    end

    # グループを設定
    Radius::Radusergroup.transaction do
      params = {groupname: "mac", priority: 1}
      update_radius_user(Radius::Radusergroup, username: username, **params)
    end

    logger.info("Added a mac address to RADIUS: #{username} - #{vlan}")
  end
end
