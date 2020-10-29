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

  node.user = User.find_by(username: data['user[username]'])

  node.place = Place.find_or_create_by(
    area: data['place[area]'] || '',
    building: data['place[building]'] || '',
    floor: data['place[floor]'] || 0,
    room: data['place[room]'] || ''
  )

  node.hardware = Hardware.find_or_create_by(
    device_type: data['hardware[device_type]'] || 'unknown',
    maker: data['hardware[maker]'] || '',
    product_name: data['hardware[product_name]'] || '',
    model_number: data['hardware[model_number]'] || ''
  )

  node.operating_system =
    if data['operating_system[os_category]']
      OperatingSystem.find_or_create_by(
        os_category: data['operating_system[os_category]'],
        name: data['operating_system[name]'] || ''
      )
    end

  network = Network.find_by(vlan: data['nic[network][vlan]'])

  node.nics = [
    Nic.new(
      interface_type: data['nic[interface_type]'] || 'unknown',
      name: data['nic[name]'],
      mac_address: data['nic[mac_address]'],
      network: Network.find_by(vlan: data['nic[network][vlan]']),
      ip_config: data['nic[ip_config]'],
      ip_address: data['nic[ip_address]'],
    ),
  ]

  if node.save
    node.id
  else
    raise node.errors.to_hash.to_s
  end
end

if $0 == __FILE__
  csv_file = ARGV[0]
  if csv_file.nil?
    warn "USAGE: rails runner #{$0} CSV_FILE"
    exit(1)
  end

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
