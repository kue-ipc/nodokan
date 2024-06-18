class KeaSubnet4AddJob < ApplicationJob
  queue_as :default

  def perform(id, ip, options, pools)
    Kea::Dhcp4Subnet.transaction do
      subnet4 = Kea::Dhcp4Subnet.find_or_initialize_by(subnet_id: id)

      Kea::Dhcp4Subnet.dhcp4_audit(cascade_transaction: subnet4.new_record?)

      subnet4.update!(subnet_prefix: "#{ip}/#{ip.prefix}")

      subnet4.dhcp4_servers = [Kea::Dhcp4Server.default]
      subnet4.dhcp4_options = options.compact.map { |name, data|
        subnet4.dhcp4_options.build(name: name, space: "dhcp4")
          .tap { |option| option.data = data }
      }
      subnet4.dhcp4_pools = pools.map { |pool|
        subnet4.dhcp4_pools
          .build(start_address: pool.first.to_i, end_address: pool.last.to_i)
      }

      subnet4.save!
    end
  end
end
