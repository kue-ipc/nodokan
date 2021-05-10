#!/usr/bin/env rails runner

require 'ipaddr'
require 'json'

require_relative 'import_csv'

class NetworkImportCSV < ImportCSV
  def create(data)
    network = Network.new

    network.name = data['name']
    network.vlan = data['vlan'].presence&.to_i
    network.auth = %w[true 1 on yes].include?(data['auth'].downcase)

    if data['ipv4_network'].present?
      address, mask = data['ipv4_network'].split('/')
      network.ipv4_network_address = address
      network.ipv4_prefix_length = mask
    end

    network.ipv4_gateway_address = data['ipv4_gateway'].presence

    if data['ipv4_pools'].present?
      JSON.parse(data['ipv4_pools']).each do |pl|
        network.ipv4_pools << Ipv4Pool.new(
          ipv4_config: pl[0],
          ipv4_first_address: pl[1],
          ipv4_last_address: pl[2]
        )
      end
    end

    if data['ipv6_network'].present?
      address, mask = data['ipv6_network'].split('/')
      network.ipv6_network_address = address
      network.ipv6_prefix_length = mask
    end

    network.ipv6_gateway_address = data['ipv6_gateway'].presence

    if data['ipv6_pools'].present?
      JSON.parse(data['ipv6_pools']).each do |pl|
        network.ipv6_pools << Ipv6Pool.new(
          ipv6_config: pl[0],
          ipv6_first_address: pl[1],
          ipv6_last_address: pl[2]
        )
      end
    end

    success = network.save
    [success, network]
  end

  def read(data)
    network = find_network(data)

    data['id'] = network.id
    data['name'] = network.name
    data['vlan'] = network.vlan
    data['auth'] = network.auth
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
    network.vlan = data['vlan'].presence&.to_i
    network.auth = %w[true 1 on yes].include?(data['auth'].downcase)

    if data['ipv4_network'].present?
      address, mask = data['ipv4_network'].split('/')
      network.ipv4_network_address = address
      network.ipv4_prefix_length = mask
    else
      network.ipv4_network_address = nil
      network.ipv4_prefix_length = nil
    end

    network.ipv4_gateway_address = data['ipv4_gateway'].presence

    network.ipv4_pools.clear
    if data['ipv4_pools'].present?
      JSON.parse(data['ipv4_pools']).each do |pl|
        network.ipv4_pools << Ipv4Pool.new(
          ipv4_config: pl[0],
          ipv4_first_address: pl[1],
          ipv4_last_address: pl[2]
        )
      end
    end

    if data['ipv6_network'].present?
      address, mask = data['ipv6_network'].split('/')
      network.ipv6_network_address = address
      network.ipv6_prefix_length = mask
    else
      network.ipv6_network_address = nil
      network.ipv6_prefix_length = nil
    end

    network.ipv6_gateway_address = data['ipv6_gateway'].presence

    network.ipv6_pools.clear
    if data['ipv6_pools'].present?
      JSON.parse(data['ipv6_pools']).each do |pl|
        network.ipv6_pools << Ipv6Pool.new(
          ipv6_config: pl[0],
          ipv6_first_address: pl[1],
          ipv6_last_address: pl[2]
        )
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
