class RadiusMacDelJob < RadiusJob
  queue_as :default

  def perform(mac_address)
    if mac_address !~ /\A[0-9a-f]{12}\z/
      raise "Cannot del the invalid mac address to RADIUS: #{mac_address}"
    end

    del_radius_user(mac_address)
  end
end
