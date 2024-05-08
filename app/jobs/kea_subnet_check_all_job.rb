class KeaSubnetCheckAllJob < ApplicationJob
  queue_as :default

  def perform
    network4_ids = Network.where(dhcp: true)
      .where.not(ipv4_network_data: nil).ids
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit
      Kea::Dhcp4Subnet.where.not(subnet_id: network4_ids).destroy_all
    end

    network6_ids = Network..where(network: {ra: ["managed", "assist"]})
      .where.not(ipv6_network_data: nil).ids
    Kea::Dhcp6Subnet.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit
      Kea::Dhcp6Subnet.where.not(subnet_id: network6_ids).destroy_all
    end
  end
end
