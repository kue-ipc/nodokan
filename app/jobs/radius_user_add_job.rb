class RadiusUserAddJob < RadiusJob
  queue_as :default

  def perform(username, vlan)
    if username =~ /\A[0-9a-f]{12}\z/
      raise "Cannot add the username like MAC address to RADIUS: #{username}"
    end

    add_radius_user(username, {type: "LDAP"}, vlan, "user")
  end
end
