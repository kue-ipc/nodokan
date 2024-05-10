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
        network.kea_subnet4 if network.ipv4_network != subnet_ip
      end

    subnet_hash.each_key do |id|
      KeaReservation6DelJob.perform_later(id)
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
        network.kea_subnet6 if network.ipv6_network != subnet_ip
      end

    subnet_hash.each_key do |id|
      KeaReservation6DelJob.perform_later(id)
    end
  end
end
