class KeaSubnet6DelJob < ApplicationJob
  queue_as :default

  def perform(network)
    if network.dhcpv6?
      logger.warn("Network needs DHCPv6, so skip to delete subnet6: " +
        netowrk.name)
      return
    end

    Kea::Dhcp6Subnet.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit
      Kea::Dhcp6Subnet.destroy_by(subnet_id: network.id)
    end
  end
end
