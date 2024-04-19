class NicsConnectedAtJob < ApplicationJob
  queue_as :default

  def perform(nic)
    # no versioning
    PaperTrail.request(enabled: false) do
      nic.ipv4_resolved_at = nic.ipv4_data && ipv4_resolved_at(nic)
      nic.ipv6_discovered_at = nic.ipv6_data && ipv6_discovered_at(nic)
      nic.ipv4_leased_at = nic.mac_address_data && ipv4_leased_at(nic)
      nic.ipv6_leased_at = nic.mac_address_data && ipv6_leased_at(nic)
      nic.auth_at = nic.mac_address_data && auth_at(nic)
      nic.skip_after_job = true
      nic.save
    end
  end

  def ipv4_resolved_at(nic)
    Ipv4Arp.where(ipv4_data: nic.ipv4_data).order(:resolved_at)
      .last&.resolved_at
  end

  def ipv6_discovered_at(nic)
    Ipv6Neighbor.where(ipv6_data: nic.ipv6_data).order(:discovered_at)
      .last&.discovered_at
  end

  def ipv4_leased_at(nic)
    Kea::Lease4.where(hwaddr: nic.mac_address_data).order(:expire)
      .last&.leased_at
  end

  def ipv6_leased_at(nic)
    Kea::Lease6.where(hwaddr: nic.mac_address_data).order(:expire)
      .last&.leased_at
  end

  def auth_at(nic)
    Radius::Radpostauth.where(username: nic.mac_address_raw).order(:authdate)
      .last&.authdate
  end
end
