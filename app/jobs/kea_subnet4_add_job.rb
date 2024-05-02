class KeaSubnet4AddJob < ApplicationJob
  queue_as :default

  def perform(network)
    unless network.dhcpv4?
      logger.warn("Network dose not need DHCPv4, so skip to add subnet4: " +
        netowrk.name)
      return
    end

    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit

      subnet4 = Kea::Dhcp4Subnet.find_or_initialize_by(subnet_id: network.id)
      subnet4.subnet_prefix = network.ipv4_network_address_prefix
      subnet4.save!

      if subnet4.dhcp4_servers.count.zero?
        subnet4.dhcp4_subnet_servers
          .create!(dhcp4_server: Kea::Dhcp4Server.default)
      end

      # 現在のところ、ゲートウェイのみ設定する
      subnet4.dhcp4_options = [subnet4.dhcp4_options.build(
        code: 3,
        formatted_value: network.ipv4_gateway_address,
        space: "dhcp4")]

      subnet4.dhcp4_pools =
        network.ipv4_pools.select(&:ipv4_dynamic?).map { |pool|
          subnet4.dhcp4_pools.build(start_address: pool.ipv4_first.to_i,
            end_address: pool.ipv4_last.to_i)
        }
    end
  end
end
