class KeaSubnet4AddJob < ApplicationJob
  queue_as :default

  def perform(network)
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit

      subnet4 = Kea::Dhcp4Subnet.find_or_initialize_by(subnet_id: network.id)
      subnet4.subnet_prefix = network.ipv4_network_prefix
      subnet4.modification_ts = Time.current
      subnet4.save!

      if subnet4.dhcp4_servers.count.zero?
        subnet4.dhcp4_subnet_servers.create!(
          dhcp4_server: Kea::Dhcp4Server.default,
          modification_ts: Time.current,
        )
      end

      subnet4.dhcp4_options = [subnet4.dhcp4_options.build(
        code: 3,
        formatted_value: network.ipv4_gateway_address,
        space: 'dhcp4',
      )]

      subnet4.dhcp4_pools = network.ipv4_pools.map do |pool|
        subnet4.dhcp4_pools.build(
          start_address: pool.ipv4_first.to_i,
          end_address: pool.ipv4_last.to_i,
        )
      end

      subnet4.modification_ts = Time.current
      subnet4.save!
    end
  end
end
