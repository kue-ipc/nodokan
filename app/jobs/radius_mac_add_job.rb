class RadiusMacAddJob < ApplicationJob
  queue_as :default

  def perform(mac_address, vlan)
    unless mac_address =~ /\A[0-9a-f]{12}\z/
      logger.error(I18n.t('invalid_mac_adderss') + ": #{mac_address}")
      return
    end

    password =
      Rails.application.credentials.dig(:config, :radius_mac_password) ||
      Settings.config.radius_mac_password ||
      mac_address

    # パスワードを設定
    radcheck = Radius::Radcheck.find_or_initialize_by(username: mac_address)
    radcheck.attr = 'Cleartext-Password'
    radcheck.op = ':='
    radcheck.value = password
    radcheck.save!

    # VLANを設定
    radreply = Radius::Radreply.find_or_initialize_by(username: mac_address)
    radreply.attr = 'Tunnel-Private-Group-Id'
    radreply.op = ':='
    radreply.value = vlan.to_s
    radreply.save!

    # グループを設定
    radusergroup =
      Radius::Radusergroup.find_or_initialize_by(username: mac_address)
    radusergroup.groupname = 'mac'
    radusergroup.priority = 1
    radusergroup.save!

    logger.info(
      I18n.t('messages.job.radius_mac_add') + ": #{mac_address} - #{vlan}"
    )
  end
end
