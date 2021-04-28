#!/usr/bin/env rails runner

require 'ipaddr'

require_relative 'import_csv'

class NodeImportCSV < ImportCSV
  def create(data)
    node = Node.new
  
    node.user = User.find_by_username(data['user'])
    node.name = data['name']
    node.hostname = data['hostname']
    node.domain = data['domain']
    node.note = data['note']
  
    node.place = Place.find_or_initialize_by(
      area: data['place[area]'] || '',
      building: data['place[building]'] || '',
      floor: data['place[floor]'] || 0,
      room: data['place[room]'] || ''
    )
  
    node.hardware = 
      if data['hardware[device_type]'].present? ||
          data['hardware[product_name]']
        Hardware.find_or_initialize_by(
          device_type: data['hardware[device_type]'] || 'unknown',
          maker: data['hardware[maker]'] || '',
          product_name: data['hardware[product_name]'] || '',
          model_number: data['hardware[model_number]'] || ''
        )
      end
  
    node.operating_system =
      if data['operating_system[os_category]'].present? ||
          data['hardware[product_name]']
        OperatingSystem.find_or_initialize_by(
          os_category: data['operating_system[os_category]'] || 'unknown',
          name: data['operating_system[name]'] || ''
        )
      end

    if data['nic[network]'].present?
      if data['nic[network]'] =~ /^\#(\d+)$/i
        network = Network.find($1)
      elsif data['nic[network]'] =~ /^v(\d+)$/i
        network = Network.find_by_vlan($1)
      else
        raise "invalid network: #{nic[]}"
      end

      if network.nil?
        raise "no network: #{data['nic[network]']}"
      end

      node.nics <<
        Nic.new(
          network: network,
          interface_type: data['nic[interface_type]'] || 'unknown',
          name: data['nic[name]'],
          mac_registration: data['nic[mac_registration]'],
          mac_address: data['nic[mac_address]'],
          duid: data['nic[duid]'],
          ipv4_config: data['nic[ipv4_config]'],
          ipv4_address: data['nic[ipv4_address]'],
          ipv6_config: data['nic[ipv6_config]'],
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
