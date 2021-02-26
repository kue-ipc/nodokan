#!/usr/bin/env rails runner

require 'csv'
require 'fileutils'
require 'logger'
require 'ipaddr'

def register_network(data)
  network = Network.new(
    name: data['name'],
    vlan: data['vlan'],
    auth: data['auth'].presence || false,
    ipv4_gateway_address: data['ipv4_gateway'],
  )
  if data['ipv4_network'].present?
    address, mask = data['ipv4_network'].split('/')
    network.ipv4_network_address = address
    network.ipv4_prefixlen = mask
  end

  ['static', 'dynamic', 'reserved'].each do |ipv4_config|
    data_name = "ipv4_pools[#{ipv4_config}]"
    if data[data_name].present?
      data[data_name].split('|').each do |ipv4_range|
        first, last = ipv4_range.split('-')
        network.ipv4_pools << Ipv4Pool.new(
          ipv4_config: ipv4_config, ipv4_first_address: first, ipv4_last_address: last)
      end
    end
  end

  if network.save
    network.id
  else
    raise network.errors.to_hash.to_s
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
  network_datas = CSV.read(csv_file, encoding: 'BOM|UTF-8', headers: :first_row)

  File.open(csv_file, 'wb:UTF-8') do |io|
    io.write "\u{feff}"
    io.puts network_datas.headers.to_csv
    network_datas.each.with_index do |data, idx|
      if data['id'] =~ /\A\d+\z/
        logger.info("#{idx}: [skip] already registered as #{data['id']}")
        next
      end

      result = register_network(data)
      data['id'] = result
    rescue StandardError => e
      logger.error(e.message)
      data['id'] = 'E'
      warn "#{idx}:#{e.message}"
    ensure
      io.puts data.to_csv
    end
  end
end
