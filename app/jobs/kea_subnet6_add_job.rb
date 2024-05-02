class KeaSubnet6AddJob < ApplicationJob
  queue_as :default

  def perform(network)
    unless network.dhcpv6?
      logger.warn("Network dose not need DHCPv6, so skip to add subnet6: " +
        netowrk.name)
      return
    end

    Kea::Dhcp6Subnet.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit

      subnet6 = Kea::Dhcp6Subnet.find_or_initialize_by(subnet_id: network.id)
      subnet6.subnet_prefix = network.ipv6_network_address_prefix
      subnet6.save!

      if subnet6.dhcp6_servers.count.zero?
        subnet6.dhcp6_subnet_servers
          .create!(dhcp6_server: Kea::Dhcp6Server.default)
      end

      # ゲートウェイは設定しない。
      # subnet6.dhcp6_options = []

      subnet6.dhcp6_pools =
        network.ipv6_pools.select(&:ipv6_dynamic?).map { |pool|
          subnet6.dhcp6_pools.build(start_address: pool.ipv6_first_address,
            end_address: pool.ipv6_last_address)
        }
    end
  end
end
