class KeaSubnet6AddJob < ApplicationJob
  queue_as :default

  def perform(id, ip, options, pools)
    create_subnet = nil
    Kea::Dhcp6Subnet.transaction do
      subnet6 = Kea::Dhcp6Subnet.find_or_initialize_by(subnet_id: id)
      create_subnet = subnet6.new_record?
      Kea::Dhcp6Subnet.dhcp6_audit(cascade_transaction: subnet6.new_record?)

      default_server = Kea::Dhcp6Server.default
      subnet_scope = Kea::DhcpOptionScope.subnet
      option_params = {
        space: "dhcp6",
        dhcp_option_scope: subnet_scope,
      }

      # アドレス範囲
      subnet6.update!(subnet_prefix: "#{ip}/#{ip.prefix}")

      # サーバー
      subnet6.dhcp6_servers = [default_server]

      # オプション
      current_options = subnet6.dhcp6_options.index_by(&:name)
      options.compact_blank
        .transform_keys { |key| Kea::Dhcp6Option.normalize_name(key) }
        .each do |key, value|
        if (existing_option = current_options.delete(key))
          existing_option.update!(data: value, **option_params)
        else
          subnet6.dhcp6_options.create!(name: key, data: value, **option_params)
        end
      end
      subnet6.dhcp6_options.destroy(*current_options.values)

      # プール
      current_pools = subnet6.dhcp6_pools.index_by(&:start_address)
      pools.each do |pool|
        if (existing_pool = current_pools.delete(pool.first.to_s))
          existing_pool.update!(end_address: pool.last.to_s)
        else
          subnet6.dhcp6_pools.create!(start_address: pool.first.to_s,
            end_address: pool.last.to_s)
        end
      end
      subnet6.dhcp6_pools.destroy(*current_pools.values)

      subnet6.save!
    end

    if create_subnet
      # check network_id, enabled?, ipv6_reserved?, has_ipv6?, node.has_duid?
      Nic.includes(:node)
        .where(network_id: id, node: {disabled: false}, ipv6_config: "reserved")
        .where.not(ipv6_data: nil)
        .where.not(node: {duid_data: nil})
        .find_each do |nic|
        KeaReservation6AddJob.perform_later(id, nic.node.duid, nic.ipv6)
      end
    end
  end
end
