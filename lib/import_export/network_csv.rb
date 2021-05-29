require 'import_export/base_csv'
require 'ipaddr'
require 'json'

module ImportExport
  class NetworkCSV < BaseCSV
    def model_class
      Network
    end

    def attrs
      %w[
        name
        flag
        vlan
        ipv4_network
        ipv4_gateway
        ipv4_pools
        ipv6_network
        ipv6_gateway
        ipv6_pools
        note
      ]
    end

    def unique_attrs
      %w[
        name
        vlan
      ]
    end

    def record_to_row(nework, row)
      row['name'] = network.name
      row['flag'] = network.flag
      row['vlan'] = network.vlan
      row['ipv4_network'] = network.ipv4_network&.to_string
      row['ipv4_gateway'] = network.ipv4_gateway
      row['ipv4_pools'] = network.ipv4_pools.map(&:identifier).join(' ')
      row['ipv6_network'] = network.ipv6_network&.to_string
      row['ipv6_gateway'] = network.ipv6_gateway
      row['ipv6_pools'] = ipv6_pools.map.map(&:identifier).join(' ')
      row['note'] = network.note
      row
    end

    def create(row)
      network = Network.new

      network.name = row['name']

      if row['flag'].present?
        row['flag'].downcase.each_char do |char|
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
            raise "Invalid flag: #{row['flag']}"
          end
        end
      end

      network.vlan = row['vlan'].presence&.to_i

      if row['ipv4_network'].present?
        address, mask = row['ipv4_network'].split('/')
        network.ipv4_network_address = address
        network.ipv4_prefix_length = mask
      end

      network.ipv4_gateway_address = row['ipv4_gateway'].presence

      if row['ipv4_pools'].present?
        row['ipv4_pools'].split.each do |pl|
          network.ipv4_pools << Ipv4Pool.new_identifier(pl)
        end
      end

      if row['ipv6_network'].present?
        address, mask = row['ipv6_network'].split('/')
        network.ipv6_network_address = address
        network.ipv6_prefix_length = mask
      end

      network.ipv6_gateway_address = row['ipv6_gateway'].presence

      if row['ipv6_pools'].present?
        row['ipv6_pools'].split.each do |pl|
          network.ipv6_pools << Ipv6Pool.new_identifier(pl)
        end
      end

      success = network.save
      [success, network]
    end

    def read(row)
      network = find_network(row)

      row['id'] = network.id
      row['name'] = network.name
      row['flag'] =   [
        if network.auth then 'a' else '' end,
        if network.dhcp then 'd' else '' end,
        if network.locked then 'l' else '' end,
        if network.specific then 's' else '' end,
      ].join(''),
    
      row['vlan'] = network.vlan
      row['ipv4_network'] = network.ipv4_network&.to_string
      row['ipv4_gateway'] = network.ipv4_gateway
      row['ipv4_pools'] =
        network.ipv4_pools.map { |pl| [pl.ipv4_config,
                                      pl.ipv4_first_address,
                                      pl.ipv4_last_address] }.to_json
      row['ipv6_network'] = network.ipv6_network&.to_string
      row['ipv6_gateway'] = network.ipv6_gateway
      row['ipv6_pools'] = 
        network.ipv6_pools.map { |pl| [pl.ipv6_config,
                                      pl.ipv6_first_address,
                                      pl.ipv6_last_address] }.to_json
      row['note'] = network.note
      row['action'] = ''
      row['result'] = 'success'

      [true, network]
    end

    def update(row)
      network = find_network(row)

      network.name = row['name']
      if row['flag'].present?
        row['flag'].downcase.each_char do |char|
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
            raise "Invalid flag: #{row['flag']}"
          end
        end
      end

      network.vlan = row['vlan'].presence&.to_i

      if row['ipv4_network'].present?
        address, mask = row['ipv4_network'].split('/')
        network.ipv4_network_address = address
        network.ipv4_prefix_length = mask
      else
        network.ipv4_network_address = nil
        network.ipv4_prefix_length = 0
      end

      network.ipv4_gateway_address = row['ipv4_gateway'].presence

      network.ipv4_pools.clear
      if row['ipv4_pools'].present?
        row['ipv4_pools'].split.each do |pl|
          network.ipv4_pools << Ipv4Pool.new_identifier(pl)
        end
      end

      if row['ipv6_network'].present?
        address, mask = row['ipv6_network'].split('/')
        network.ipv6_network_address = address
        network.ipv6_prefix_length = mask
      else
        network.ipv6_network_address = nil
        network.ipv6_prefix_length = 0
      end

      network.ipv6_gateway_address = row['ipv6_gateway'].presence

      network.ipv6_pools.clear
      if row['ipv6_pools'].present?
        row['ipv6_pools'].split.each do |pl|
          network.ipv6_pools << Ipv6Pool.new_identifier(pl)
        end
      end

      success = network.save
      [success, network]
    end

    def delete_network(row)
      network = find_network(row)

      success = netowrk.destory
      [success, network]
    end
  end
end
