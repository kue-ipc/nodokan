class KeaSubnet4AddJob < ApplicationJob
  queue_as :default

  def perform(network)
    if !network.dhcp || network.ipv4_network.nil?
      return
    end

    subnet4 = Kea::Dhcp4Subnet.find_or_initialize_by(subnet_id: network.id)
    subnet4.subnet_prefix = network.ipv4_network_prefix
    subnet4.modification_ts = Time.now
    unless subnet4.save
      logger.info("KEAデータベースで、IPv4サブネットを登録できませんでした。: #{network.name} - #{subnet4.errors.to_json}")
      return
    end

    if subnet4.dhcp4_servers.count.zero?
      unless subnet4.dhcp4_subnet_servers.create(
        dhcp4_server: Kea::Dhcp4Server.default,
        modification_ts: Time.now
      )
        logger.info("KEAデータベースで、IPv4サブネットをサーバーに登録できませんでした。: #{network.name} - #{subnet4.errors.to_json}")
        return
      end
    end

    subnet4.dhcp4_pools = network.ipv4_pools.map do |pool|
      subnet4.dhcp4_pools.build(
        start_address: pool.ipv4_first.to_i,
        end_address: pool.ipv4_last.to_i)
    end

    subnet4.modification_ts = Time.now
    if subnet4.save
      logger.info("KEAデータベースにIPv4サブネットを登録しました。: #{network.name}")
    else
      logger.info("KEAデータベースにIPv4サブネットを登録できませんでした。: #{network.name} - #{subnet4.errors.to_json}")
    end
  end
end
