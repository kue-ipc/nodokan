class RadiusUserDelJob < RadiusJob
  queue_as :default

  def perform(username)
    if username =~ /\A[0-9a-f]{12}\z/
      raise "Cannot del the username like MAC address to RADIUS: #{username}"
    end

    del_radius_user(username)
  end
end
