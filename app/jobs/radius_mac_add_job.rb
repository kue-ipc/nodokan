class RadiusMacAddJob < ApplicationJob
  queue_as :default

  def perform(mac_address_raw, vlan)
    if mac_address_raw !~ /\A[0-9a-f]{12}\z/
      logger.error("Cannot add a invalid mac address to RADIUS: #{mac_address_raw}")
      # TODO: 管理者に通知を送る。
      return
    end

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
  rescue StandardError => e
    logger.error("Failed to add a mac address to RADIUS: #{username} - #{e.message}")
    logger.error(e.full_message)
    # TODO: 管理者に通知を送る。
  end
end
