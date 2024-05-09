class KeaSubnet4AddJob < ApplicationJob
  queue_as :default

  def perform(id, ip, options, pools)
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit

      subnet4 = Kea::Dhcp4Subnet.find_or_initialize_by(subnet_id: id)
      subnet4.update!(subnet_prefix: "#{ip}/#{ip.prefix}")

      if subnet4.dhcp4_servers.count.zero?
        subnet4.dhcp4_subnet_servers
          .create!(dhcp4_server: Kea::Dhcp4Server.default)
      end

      subnet4.dhcp4_options = options.map { |name, data|
        subnet4.dhcp4_options
          .build(name: name, space: "dhcp4")
          .tap { |option| option.data = data }
      }

      subnet4.dhcp4_pools = pools.map { |pool|
        subnet4.dhcp4_pools.build(
          start_address: pool.first.to_i,
          end_address: pool.last.to_i)
      }
    end
  end
end
