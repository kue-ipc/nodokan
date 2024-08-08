class KeaSubnet6AddJob < ApplicationJob
  queue_as :default

  def perform(id, ip, options, pools)
    Kea::Dhcp6Subnet.transaction do
      subnet6 = Kea::Dhcp6Subnet.find_or_initialize_by(subnet_id: id)

      Kea::Dhcp6Subnet.dhcp6_audit(cascade_transaction: subnet6.new_record?)

      subnet6.update!(subnet_prefix: "#{ip}/#{ip.prefix}")

      subnet6.dhcp6_servers = [Kea::Dhcp6Server.default]
      subnet6.dhcp6_options = options.compact.map do |name, data|
        subnet6.dhcp6_options.build(name: name, space: "dhcp6")
          .tap { |option| option.data = data }
      end
      subnet6.dhcp6_pools = pools.map do |pool|
        subnet6.dhcp6_pools
          .build(start_address: pool.first.to_s, end_address: pool.last.to_s)
      end

      subnet6.save!
    end
  end
end
