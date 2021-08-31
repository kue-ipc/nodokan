class NicsConnectedAtJob < ApplicationJob
  queue_as :default

  def perform(nic)
    nic.ipv4_resolved_at = nic.ipv4_data &&
      Ipv4Arp.where(ipv4_data: nic.ipv4_data).order(:resolved_at).last&.resolved_at

    nic.ipv6_discovered_at = nic.ipv6_data &&
      Ipv6Neighbor.where(ipv6_data: nic.ipv6_data).order(:discovered_at).last&.discovered_at

    nic.ipv4_leased_at = nic.mac_address_data &&
      Kea::Lease4.where(hwaddr: nic.mac_address_data).order(:expire).last&.leased_at

    nic.ipv6_leased_at = nic.mac_address_data &&
      Kea::Lease6.where(hwaddr: nic.mac_address_data).order(:expire).last&.leased_at

    nic.auth_at = nic.mac_address_data &&
      Radius::Radpostauth.where(username: nic.mac_address_raw).order(:authdate).last&.authdate

    nic.save
  end
end
