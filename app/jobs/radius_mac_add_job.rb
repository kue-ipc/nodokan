class RadiusMacAddJob < RadiusJob
  queue_as :default

  def perform(mac_address, vlan)
    if mac_address !~ /\A[0-9a-f]{12}\z/
      raise "Cannot add the invalid mac address to RADIUS: #{mac_address}"
    end

    # NOTE: 設定されていなければ、MACアドレスと同じにする。
    password =
      Rails.application.credentials.dig(:config, :radius_mac_password) ||
      Settings.config.radius_mac_password ||
      mac_address

    add_radius_user(mac_address, {password:}, vlan, "mac")
  end
end
