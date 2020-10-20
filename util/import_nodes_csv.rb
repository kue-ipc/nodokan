#!/usr/bin/env rails runner

require 'csv'
require 'fileutils'
require 'logger'
require 'ipaddr'

def register_node(data)
  node = Node.new(
    name: data['name'],
    hostname: data['hostname'],
    domain: data['domain']
  )

  node.user = User.find_by(username: data['user'])

  node.place = Place.find_or_create_by(
    area: data['place[area]'] || '',
    building: data['place[building]'] || '',
    floor: data['place[floor]'] || 0,
    room: data['place[room]'] || ''
  )

  node.hardware = Hardware.find_or_create_by(
    category: data['hardware[category]'] || 'unknown',
    maker: data['hardware[maker]'] || '',
    product_name: data['hardware[product_name]'] || '',
    model_number: data['hardware[model_number]'] || ''
  )

  node.operating_system =
    if data['operating_system[category]']
      OperatingSystem.find_or_create_by(
        category: data['operating_system[category]'],
        name: data['operating_system[name]'] || ''
      )
    end

  node.security_software =
    if data['security_software[name]'].present?
      SecuritySoftware.find_or_create_by(
        name: data['security_software[name]']
      )
    end

  ip_addr =
    (IPAddr.new(data['network[address]']) if data['network[address]'].present?)

  subnetwork = Subnetwork.find_by(vlan: data['network[vlan]'])
  raise "not exist valn: #{data['network[vlan]']}" if subnetwork.nil?

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
              family: (ip_addr&.ipv6? ? :ipv6 : :ipv4),
              address: ip_addr&.to_s
            ),
          ]
        ),
      ]
    ),
  ]
  if node.save
    node.id
  else
    raise node.errors.to_hash.to_s
  end
end

if $0 == __FILE__
  csv_file = Rails.root / 'util' / 'data' / 'nodes.csv'
  backup_csv_file = "#{csv_file}.#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}"
  logger = Logger.new($stderr)

  FileUtils.copy_file(csv_file, backup_csv_file)
  node_datas = CSV.read(csv_file, encoding: 'BOM|UTF-8', headers: :first_row)

  File.open(csv_file, 'wb:UTF-8') do |io|
    io.write "\u{feff}"
    io.puts node_datas.headers.to_csv
    node_datas.each.with_index do |data, idx|
      if data['id'] =~ /\A\d+\z/
        logger.info("#{idx}: [skip] already registered as #{idx}")
        next
      end

      result = register_node(data)
      data['id'] = result
    rescue StandardError => e
      logger.error(e.message)
      data['id'] = 'E'
      data['note'] = e.message
    ensure
      io.puts data.to_csv
    end
  end
end
