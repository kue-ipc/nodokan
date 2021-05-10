# mac address style: hhhhhhhhhhhh
#   - lowercase
#   - no separator
#   - 12 chars 0-9a-f

class RadiusRegisterMacJob < ApplicationJob
  queue_as :default

  def perform(mac_address, vlan)
    unless mac_address =~ /\A[0-9a-f]{12}\z/
      logger.error("不正なMACアドレスです: #{mac_address}")
      return
    end

    password = Settings.config.radius_mac_password || mac_address

    # パスワードを設定
    Radius::Radcheck.find_or_initialize_by(username: mac_address)
      .tap do |radcheck|
      radcheck.attr = 'Cleartext-Password'
      radcheck.op = ':='
      radcheck.value = password
      radcheck.save!
    end

    # VLANを設定
    Radius::Radreply.find_or_initialize_by(username: mac_address)
      .tap do |radreply|
      radreply.attr = 'Tunnel-Private-Group-Id'
      radreply.op = ':='
      radreply.value = vlan.to_s
      radreply.save!
    end

    # グループを設定
    Radius::Radusergroup.find_or_initialize_by(username: mac_address)
      .tap do |radusergroup|
      radusergroup.groupname = 'mac'
      radusergroup.priority = 1
      radusergroup.save!
    end

    logger.info("MACアドレスを登録しました。: #{mac_address} - #{vlan}")
  end
end