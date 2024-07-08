class NicsConnectedAtJob < ApplicationJob
  queue_as :default

  def perform(nic)
    current_times = [
      :ipv4_resolved_at,
      :ipv6_discovered_at,
      :ipv4_leased_at,
      :ipv6_leased_at,
      :auth_at,
    ].to_h { |name| [name, nic.__send__(name)] }
    new_times = {
      ipv4_resolved_at: ipv4_resolved_at(nic),
      ipv6_discovered_at: ipv6_discovered_at(nic),
      ipv4_leased_at: ipv4_leased_at(nic),
      ipv6_leased_at: ipv6_leased_at(nic),
      auth_at: auth_at(nic),
    }

    if new_times != current_times
      # no verify nor callback nor versioning
      nic.update_columns(new_times)
    end
  end

  def ipv4_resolved_at(nic)
    if nic.has_mac_address?
      Ipv4Arp.where(mac_address_data: nic.mac_address_data)
        .order(resolved_at: :desc).pick(:resolved_at)
    elsif nic.has_ipv4?
      Ipv4Arp.where(ipv4_data: nic.ipv4_data)
        .order(resolved_at: :desc).pick(:resolved_at)
    end
  end

  def ipv6_discovered_at(nic)
    if nic.has_mac_address?
      Ipv6Neighbor.where(mac_address_data: nic.mac_address_data)
        .order(discovered_at: :desc).pick(:discovered_at)
    elsif nic.has_ipv6?
      Ipv6Neighbor.where(ipv6_data: nic.ipv6_data)
        .order(discovered_at: :desc).pick(:discovered_at)
    end
  end

  def ipv4_leased_at(nic)
    return unless nic.has_mac_address? && nic.network_id

    Kea::Lease4.where(hwaddr: nic.mac_address_data, subnet_id: nic.network_id)
      .order(expire: :desc).pick(:expire, :valid_lifetime)
      &.then { |expire, valid_lifetime| expire - valid_lifetime }
  end

  def ipv6_leased_at(nic)
    return unless nic.node.has_duid? && nic.network_id

    Kea::Lease6.where(duid: nic.node.duid_data, subnet_id: nic.network_id)
      .order(expire: :desc).pick(:expire, :valid_lifetime)
      &.then { |expire, valid_lifetime| expire - valid_lifetime }
  end

  def acct_at(nic)
    return unless nic.has_mac_address?

    Radius::Radacct.where(username: nic.mac_address_raw)
      .order(acctupdatetime: :desc).pick(:acctupdatetime)
  end

  def auth_at(nic)
    return unless nic.has_mac_address?

    Radius::Radpostauth
      .where(username: nic.mac_address_raw, reply: "Access-Accept")
      .order(authdate: :desc).pick(:authdate)
  end
end
