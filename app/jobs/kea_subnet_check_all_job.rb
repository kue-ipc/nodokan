class KeaSubnetCheckAllJob < ApplicationJob
  queue_as :default

  def perform
    check_subnet4
    check_subnet6
  end

  def check_subnet4
    subnet_hash = Kea::Dhcp4Subnet.all
      .to_h { |subnet| [subnet.subnet_id, subnet.ipv4] }

    Network
      .where.not(ipv4_network_data: nil)
      .where(dhcp: true)
      .find_each do |network|
        subnet_ip = subnet_hash.delete(network.id)
        if network.ipv4_network_prefix != subnet_ip
          logger.warn "IPv4 subnet is defferent for Network##{network.id}"
          network.kea_subnet4
        end
      end

    subnet_hash.each_key do |id|
      logger.warn "Should delete DHCPv4 subnet for Network##{id}"
      KeaSubnet6DelJob.perform_later(id)
    end
  end

  def check_subnet6
    subnet_hash = Kea::Dhcp6Subnet.all
      .to_h { |subnet| [subnet.subnet_id, subnet.ipv6] }

    Network
      .where.not(ipv6_network_data: nil)
      .where(ra: ["managed", "assist"])
      .find_each do |network|
      subnet_ip = subnet_hash.delete(network.id)
      if network.ipv6_network_prefix != subnet_ip
        logger.warn "IPv6 subnet is defferent for Network##{network.id}"
        network.kea_subnet6
      end
    end

    subnet_hash.each_key do |id|
      logger.warn "Should delete DHCPv6 subnet for Network##{id}"
      KeaSubnet6DelJob.perform_later(id)
    end
  end
end
