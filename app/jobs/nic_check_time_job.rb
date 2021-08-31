class NicCheckTimeJob < ApplicationJob
  queue_as :default

  def perform(nic)
    if nic.ipv4_data
      nic.ipv4_resolved_at = Ipv4Arp.where(ipv4_data: nic.ipv4_data).order(:resolved_at).last&.resolved_at
    end

    if nic.ipv6_data
      nic.ipv6_discovered_at = Ipv6Neighbor.where(ipv6_data: nic.ipv6_data).order(:discovered_at).last&.discovered_at
    end

    if nic.mac_address_data
      if (lease4 = Kea::Lease4.where(hwaddr: nic.mac_address_data).order(:expire).last)
        nic.ipv4_leased_at = lease4.leased_at
      end

      if (lease6 = Kea::Lease6.where(hwaddr: nic.mac_address_data).order(:expire).last)
        nic.ipv6_leased_at = lease6.leased_at
      end

      if (auth = Radius::Radpostauth.where(username: nic.mac_address_raw).order(:authdate).last)
        nic.auth_at = auth.authdate
      end
    end

    nic.save
  end
end
