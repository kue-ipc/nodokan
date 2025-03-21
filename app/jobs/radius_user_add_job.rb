class RadiusUserAddJob < RadiusJob
  queue_as :default

  def perform(username, vlan)
    if username =~ /\A[0-9a-f]{12}\z/
      raise "Cannot add the username like MAC address to RADIUS: #{username}"
    end

    # Auth-Typeを設定
    update_radius_user(Radius::Radcheck, username,
      attr: "Auth-Type", op: ":=", value: "LDAP")

    # VLANを設定
    update_radius_user(Radius::Radreply, username,
      attr: "Tunnel-Private-Group-Id", op: ":=", value: vlan.to_s)

    # グループを設定
    update_radius_user(Radius::Radusergroup, username,
      groupname: "user", priority: 1)

    logger.info("Added a user name to RADIUS: #{username} - #{vlan}")
  end
end
