class NicRegistAuthJob < ApplicationJob
  queue_as :default

  def perform(nic)
    mac_address = nic.mac_address(char_case: :lower, sep: '')
    password = Settings.config.radius_mac_password || mac_address

    # パスワードを設定
    radcheck = Radius::Radcheck.find_or_initialize_by(username: mac_address)
    radcheck.attr = 'Cleartext-Password'
    radcheck.op = ':='
    radcheck.value = password
    radcheck.save

    # VLANを設定
    radreply = Radius::Radreply.find_or_initialize_by(username: mac_address)
    radreply.attr = 'Tunnel-Private-Group-Id'
    radreply.op = ':='
    radreply.value = nic.network.vlan.to_s
    radreply.save

    # グループを設定
    radusergroup =
      Radius::Radusergroup.find_or_initialize_by(username: mac_address)
    radusergroup.groupname = 'mac'
    radusergroup.priority = 1
    radusergroup.save
  end
end
