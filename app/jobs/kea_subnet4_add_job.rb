class KeaSubnet4AddJob < ApplicationJob
  queue_as :default

  def perform(id, ip, options, pools)
    Kea::Dhcp4Subnet.transaction do
      subnet4 = Kea::Dhcp4Subnet.find_or_initialize_by(subnet_id: id)
      Kea::Dhcp4Subnet.dhcp4_audit(cascade_transaction: subnet4.new_record?)

      # アドレス範囲
      subnet4.update!(subnet_prefix: "#{ip}/#{ip.prefix}")

      # サーバー
      subnet4.dhcp4_servers = [Kea::Dhcp4Server.default]

      # オプション
      current_options = subnet4.dhcp4_options.index_by(&:name)
      options.compact_blank
        .transform_keys { |key| Kea::Dhcp4Option.normalize_name(key) }
        .each do |key, value|
        if (existing_option = current_options.delete(key))
          existing_option.update!(data: value)
        else
          subnet4.dhcp4_options.create!(name: key, data: value, space: "dhcp4")
        end
      end
      subnet4.dhcp4_options.destroy(*current_options.values)

      # プール
      current_pools = subnet4.dhcp4_pools.index_by(&:start_address)
      pools.each do |pool|
        if (existing_pool = current_pools.delete(pool.first.to_i))
          existing_pool.update!(end_address: pool.last.to_i)
        else
          subnet4.dhcp4_pools.create!(start_address: pool.first.to_i,
            end_address: pool.last.to_i)
        end
      end
      subnet4.dhcp4_pools.destroy(*current_pools.values)

      subnet4.save!
    end
  end
end
