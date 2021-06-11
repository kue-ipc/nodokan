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
      radcheck = Radius::Radcheck.find_or_initialize_by(username: username)
      radcheck.attr = 'Cleartext-Password'
      radcheck.op = ':='
      radcheck.value = password
      radcheck.save!
    end

    # VLANを設定
    Radius::Radreply.transaction do
      radreply = Radius::Radreply.find_or_initialize_by(username: username)
      radreply.attr = 'Tunnel-Private-Group-Id'
      radreply.op = ':='
      radreply.value = vlan.to_s
      radreply.save
    end

    # グループを設定
    Radius::Radusergroup.transaction do
      radusergroup = Radius::Radusergroup.find_or_initialize_by(username: username)
      radusergroup.groupname = 'mac'
      radusergroup.priority = 1
      radusergroup.save
    end
  end
end
