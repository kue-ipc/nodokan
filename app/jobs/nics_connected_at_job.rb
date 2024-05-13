class NicsConnectedAtJob < ApplicationJob
  queue_as :default

  def perform(nic)
    # no versioning
    PaperTrail.request(enabled: false) do
      nic.ipv4_resolved_at = ipv4_resolved_at(nic)
      nic.ipv6_discovered_at = ipv6_discovered_at(nic)
      nic.ipv4_leased_at = ipv4_leased_at(nic)
      nic.ipv6_leased_at = ipv6_leased_at(nic)
      nic.auth_at = auth_at(nic)
      nic.skip_after_job = true
      nic.save
    end
  end

  def ipv4_resolved_at(nic)
    if nic.has_mac_address?
      Ipv4Arp.where(mac_address_data: nic.mac_address_data)
        .order(:resolved_at).last&.resolved_at
    elsif nic.has_ipv4?
      Ipv4Arp.where(ipv4_data: nic.ipv4_data)
        .order(:resolved_at).last&.resolved_at
    end
  end

  def ipv6_discovered_at(nic)
    if nic.has_mac_address?
      Ipv6Neighbor.where(mac_address_data: nic.mac_address_data)
        .order(:discovered_at).last&.discovered_at
    elsif nic.has_ipv6?
      Ipv6Neighbor.where(ipv6_data: nic.ipv6_data)
        .order(:discovered_at).last&.discovered_at
    end
  end

  def ipv4_leased_at(nic)
    return unless nic.has_mac_address? && nic.network_id

    Kea::Lease4.where(hwaddr: nic.mac_address_data, subnet_id: nic.network_id)
      .order(:expire).last&.leased_at
  end

  def ipv6_leased_at(nic)
    return unless nic.node.has_duid? && nic.network_id

    Kea::Lease6.where(duid: nic.node.duid_data, subnet_id: nic.network.id)
      .order(:expire).last&.leased_at
  end

  def auth_at(nic)
    return unless nic.has_mac_address?

    Radius::Radpostauth.where(username: nic.mac_address_raw)
      .order(:authdate).last&.authdate
  end
end
