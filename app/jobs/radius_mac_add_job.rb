class RadiusMacAddJob < ApplicationJob
  queue_as :default

  def perform(mac_address_raw, vlan)
    if mac_address_raw !~ /\A[0-9a-f]{12}\z/
      logger.error("Cannot add a invalid mac address to RADIUS: #{mac_address_raw}")
      # TODO
      # 管理者に通知を送る。
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
      params = { attr: "Cleartext-Password", op: ":=", value: password }
      Radius::Radcheck.find_or_create_by!(username: username, **params)
      Radius::Radcheck.where(username: username).where.not(**params).destroy_all
    end

    # VLANを設定
    Radius::Radreply.transaction do
      params = { attr: "Tunnel-Private-Group-Id", op: ":=", value: vlan.to_s }
      Radius::Radreply.find_or_create_by!(username: username, **params)
      Radius::Radreply.where(username: username).where.not(**params).destroy_all
    end

    # グループを設定
    Radius::Radusergroup.transaction do
      params = { groupname: "mac", priority: 1 }
      Radius::Radusergroup.find_or_create_by!(username: username, **params)
      Radius::Radusergroup.where(username: username).where.not(**params).destroy_all
    end
  end
end
