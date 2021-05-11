#!/usr/bin/env rails runner

require 'ipaddr'
require 'json'

require_relative 'import_csv'

class NetworkImportCSV < ImportCSV
  def create(data)
    network = Network.new

    network.name = data['name']

    if data['flag'].present?
      data['flag'].downcase.each_char do |char|
        case char
        when 'a'
          network.auth = true
        when 'd'
          network.dhcp = true
        when 'l'
          network.locked = true
        when 's'
          network.specific = true
        else
          raise "Invalid flag: #{data['flag']}"
        end
      end
    end

    network.vlan = data['vlan'].presence&.to_i

    if data['ipv4_network'].present?
      address, mask = data['ipv4_network'].split('/')
      network.ipv4_network_address = address
      network.ipv4_prefix_length = mask
    end

    network.ipv4_gateway_address = data['ipv4_gateway'].presence

    if data['ipv4_pools'].present?
      data['ipv4_pools'].split.each do |pl|
        network.ipv4_pools << Ipv4Pool.new_identifier(pl)
      end
    end

    if data['ipv6_network'].present?
      address, mask = data['ipv6_network'].split('/')
      network.ipv6_network_address = address
      network.ipv6_prefix_length = mask
    end

    network.ipv6_gateway_address = data['ipv6_gateway'].presence

    if data['ipv6_pools'].present?
      data['ipv6_pools'].split.each do |pl|
        network.ipv6_pools << Ipv6Pool.new_identifier(pl)
      end
    end

    success = network.save
    [success, network]
  end

  def read(data)
    network = find_network(data)

    data['id'] = network.id
    data['name'] = network.name
    data['flag'] =   [
      if network.auth then 'a' else '' end,
      if network.dhcp then 'd' else '' end,
      if network.locked then 'l' else '' end,
      if network.specific then 's' else '' end,
    ].join(''),
  
    data['vlan'] = network.vlan
    data['ipv4_network'] = network.ipv4_network&.to_string
    data['ipv4_gateway'] = network.ipv4_gateway
    data['ipv4_pools'] =
      network.ipv4_pools.map { |pl| [pl.ipv4_config,
                                    pl.ipv4_first_address,
                                    pl.ipv4_last_address] }.to_json
    data['ipv6_network'] = network.ipv6_network&.to_string
    data['ipv6_gateway'] = network.ipv6_gateway
    data['ipv6_pools'] = 
      network.ipv6_pools.map { |pl| [pl.ipv6_config,
                                    pl.ipv6_first_address,
                                    pl.ipv6_last_address] }.to_json
    data['note'] = network.note
    data['action'] = ''
    data['result'] = 'success'

    [true, network]
  end

  def update(data)
    network = find_network(data)

    network.name = data['name']
    if data['flag'].present?
      data['flag'].downcase.each_char do |char|
        case char
        when 'a'
          network.auth = true
        when 'd'
          network.dhcp = true
        when 'l'
          network.locked = true
        when 's'
          network.specific = true
        else
          raise "Invalid flag: #{data['flag']}"
        end
      end
    end

    network.vlan = data['vlan'].presence&.to_i

    if data['ipv4_network'].present?
      address, mask = data['ipv4_network'].split('/')
      network.ipv4_network_address = address
      network.ipv4_prefix_length = mask
    else
      network.ipv4_network_address = nil
      network.ipv4_prefix_length = 0
    end

    network.ipv4_gateway_address = data['ipv4_gateway'].presence

    network.ipv4_pools.clear
    if data['ipv4_pools'].present?
      data['ipv4_pools'].split.each do |pl|
        network.ipv4_pools << Ipv4Pool.new_identifier(pl)
      end
    end

    if data['ipv6_network'].present?
      address, mask = data['ipv6_network'].split('/')
      network.ipv6_network_address = address
      network.ipv6_prefix_length = mask
    else
      network.ipv6_network_address = nil
      network.ipv6_prefix_length = 0
    end

    network.ipv6_gateway_address = data['ipv6_gateway'].presence

    network.ipv6_pools.clear
    if data['ipv6_pools'].present?
      data['ipv6_pools'].split.each do |pl|
        network.ipv6_pools << Ipv6Pool.new_identifier(pl)
      end
    end

    success = network.save
    [success, network]
  end

  def delete_network(data)
    network = find_network(data)

    success = netowrk.destory
    [success, network]
  end

  def find_network(data)
    if data['id'].present?
      Network.find(data['id'])
    elsif data['name'].present?
      Network.find_by_name(data['name'])
    elsif data['vlan'].present?
      Network.find_by_name(data['vlan'])
    else
      raise 'no key'
    end
  end
end

if $0 == __FILE__
  ic = NetworkImportCSV.new
  ic.run(ARGV)
end
