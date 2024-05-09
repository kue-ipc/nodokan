class KeaSubnet6AddJob < ApplicationJob
  queue_as :default

  def perform(id, ip, options, pools)
    Kea::Dhcp6Subnet.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit

      subnet6 = Kea::Dhcp6Subnet.find_or_initialize_by(subnet_id: id)
      subnet6.update!(subnet_prefix: "#{ip}/#{ip.prefix}")

      if subnet6.dhcp6_servers.count.zero?
        subnet6.dhcp6_subnet_servers
          .create!(dhcp6_server: Kea::Dhcp6Server.default)
      end

      subnet6.dhcp6_options = options.map { |name, data|
        subnet6.dhcp6_options
          .build(name: name, space: "dhcp6")
          .tap { |option| option.data = data }
      }

      subnet6.dhcp6_pools = pools.map { |pool|
        subnet6.dhcp6_pools.build(
          start_address: pool.first.to_s,
          end_address: pool.last.to_s)
      }
    end
  end
end
