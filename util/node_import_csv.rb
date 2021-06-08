#!/usr/bin/env rails runner

require 'ipaddr'

require_relative 'import_csv'

class NodeImportCSV < ImportCSV
  def create(data)
    node = Node.new

    node.user = User.find_by(username: data['user'])
    node.name = data['name']
    node.hostname = data['hostname']
    node.domain = data['domain']
    node.note = data['note']

    node.place = Place.find_or_initialize_by(
      area: data['place[area]'] || '',
      building: data['place[building]'] || '',
      floor: data['place[floor]'].presence || 0,
      room: data['place[room]'] || '',
    )

    node.hardware =
      if data['hardware[device_type]'].present? ||
         data['hardware[product_name]']
        Hardware.find_or_initialize_by(
          device_type: DeviceType.find_by(name: data['hardware[device_type]']),
          maker: data['hardware[maker]'] || '',
          product_name: data['hardware[product_name]'] || '',
          model_number: data['hardware[model_number]'] || '',
        )
      end

    node.operating_system =
      if data['operating_system[os_category]'].present?
        OperatingSystem.find_or_initialize_by(
          os_category: Opreting_system.find_by(name: data['operating_system[os_category]']),
          name: data['operating_system[name]'] || '',
        )
      end

    if data['nic[network]'].present?
      case data['nic[network]']
      when /^\#(\d+)$/i
        network = Network.find(Regexp.last_match(1))
      when /^v(\d+)$/i
        network = Network.find_by(vlan: Regexp.last_match(1))
      else
        raise "invalid network: #{nic[]}"
      end

      raise "no network: #{data['nic[network]']}" if network.nil?

      node.nics <<
        Nic.new(
          network: network,
          interface_type: data['nic[interface_type]'].presence || 'unknown',
          name: data['nic[name]'],
          auth:
            %w[true 1 on yes].include?(data['nic[auth]']&.downcase),
          mac_address: data['nic[mac_address]'],
          duid: data['nic[duid]'],
          ipv4_config: data['nic[ipv4_config]'].presence || 'disabled',
          ipv4_address: data['nic[ipv4_address]'],
          ipv6_config: data['nic[ipv6_config]'].presence || 'disabled',
          ipv6_address: data['nic[ipv6_address]'],
        )
    end

    success = node.save
    [success, node]
  end
end

if $0 == __FILE__
  ic = NodeImportCSV.new
  ic.run(ARGV)
end
