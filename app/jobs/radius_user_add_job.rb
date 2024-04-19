class RadiusUserAddJob < ApplicationJob
  queue_as :default

  def perform(username, vlan)
    if username =~ /\A[0-9a-f]{12}\z/
      raise "Cannot add a user name in MAC address format to " \
            "RADIUS: #{username}"
    end

    # Auth-Typeを設定
    Radius::Radcheck.transaction do
      params = {attr: "Auth-Type", op: ":=", value: "LDAP"}
      update_radius_user(Radius::Radcheck, username: username, **params)
    end

    # VLANを設定
    Radius::Radreply.transaction do
      params = {attr: "Tunnel-Private-Group-Id", op: ":=", value: vlan.to_s}
      update_radius_user(Radius::Radreply, username: username, **params)
    end

    # グループを設定
    Radius::Radusergroup.transaction do
      params = {groupname: "user", priority: 1}
      update_radius_user(Radius::Radusergroup, username: username, **params)
    end

    logger.info("Added a user name to RADIUS: #{username} - #{vlan}")
  end
end
