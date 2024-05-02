class KeaSubnet4DelJob < ApplicationJob
  queue_as :default

  def perform(network)
    if network.dhcpv4?
      logger.warn("Network needs DHCPv4, so skip to delete subnet4: " +
        netowrk.name)
      return
    end

    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit
      Kea::Dhcp4Subnet.destroy_by(subnet_id: network.id)
    end
  end
end
