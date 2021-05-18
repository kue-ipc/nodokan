class KeaSubnet4AddJob < ApplicationJob
  queue_as :default

  def perform(network)
    if !network.dhcp || network.ipv4_network.nil?
      return
    end

    subnet4 = Kea::Dhcp4Subnet.find_or_initialize_by(subnet_id: network.id)
    subnet4.subnet_prefix = network.ipv4_network_prefix
    unless subnet4.save
      logger.info("KEAデータベースにIPv4サブネットを登録できませんでした。: #{network.name} - #{subnet4.errors.to_json}")
      return
    end

    subnet4.dhcp4_pools = network.ipv4_pools.map do |pool|
      subnet4.dhcp4_pools.build(
        start_address: pool.ipv4_first.to_i,
        end_address: pool.ipv4_last.to_i)
    end

    if subnet4.save
      logger.info("KEAデータベースにIPv4サブネットを登録しました。: #{network.name}")
    else
      logger.info("KEAデータベースにIPv4サブネットを登録できませんでした。: #{network.name} - #{subnet4.errors.to_json}")
    end
  end
end
