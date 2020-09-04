#!/usr/bin/env rails runner

require 'csv'
require 'fileutils'
require 'logger'
require 'ipaddr'

$logger = Logger.new($stderr)

def register_node(data)
  node = Node.new(
    name: data['name'],
    hostname: data['hostname'],
    domain: data['domain'],
  )

  node.user = User.find_by_username(data['user'])

  node.place = Place.find_or_create_by(
    area: data['place[area]'] || '',
    building: data['place[building]'] || '',
    floor: data['place[floor]'] || 0,
    room: data['place[room]'] || '',
  )

  node.hardware = Hardware.find_or_create_by(
    category: data['hardware[category]'] || 'unknown',
    maker: data['hardware[maker]'] || '',
    product_name: data['hardware[product_name]'] || '',
    model_number: data['hardware[model_number]'] || '',
  )

  node.operating_system = if data['operating_system[category]']
    OperatingSystem.find_or_create_by(
      category: data['operating_system[category]'],
      name: data['operating_system[name]'] || '',
    )
  end

  node.security_software = if data['security_software[name]'].present?
    SecuritySoftware.find_or_create_by(
      name: data['security_software[name]'],
    )
  end

  ip_addr =
    if data['network[address]'] && !data['network[address]'].empty?
      IPAddr.new(data['network[address]'])
    end

  subnetwork = Subnetwork.find_by_vlan(data['network[vlan]'])
  if subnetwork.nil?
    raise "not exist valn: #{data['network[vlan]']}"
  end

  node.network_interfaces = [
    NetworkInterface.new(
      interface_type: data['network[interface_type]'] || 'unknown',
      name: data['network[interface_type]'],
      mac_address: data['network[mac_address]'],
      network_connections: [
        NetworkConnection.new(
          subnetwork: subnetwork,
          ip_addresses: [
            IpAddress.new(
              config: data['network[config]'],
              family: (if ip_addr&.ipv6? then :ipv6 else :ipv4 end),
              address: ip_addr&.to_s,
            )
          ]
        )
      ]
    )
  ]
  if node.save
    node.id
  else
    raise node.errors.to_hash.to_s
  end
end

if $0 == __FILE__
  csv_file = File.join(Rails.root, 'util', 'data', 'nodes.csv')
  backup_csv_file = csv_file + '.' + Time.now.strftime("%Y%m%d-%H%M%S")

  FileUtils.copy_file(csv_file, backup_csv_file)
  node_datas = CSV.read(csv_file, encoding: 'BOM|UTF-8', headers: :first_row)

  File.open(csv_file, 'wb:UTF-8') do |io|
    io.write "\u{feff}"
    io.puts node_datas.headers.to_csv
    node_datas.each.with_index do |data, idx|
      if data['id'] =~ /\A\d+\z/
        $logger.info("#{idx}: [skip] already registered as #{idx}")
        next
      end

      result = register_node(data)
      data['id'] = result
    rescue => e
      $logger.error(e.message)
      data['id'] = 'E'
      data['note'] = e.message
    ensure
      io.puts data.to_csv
    end
  end
end
