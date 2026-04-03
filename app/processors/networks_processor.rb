class NetworksProcessor < ApplicationProcessor
  model_name "Network"

  keys [
    :name, :vlan, :domain, {domain_search: []},
    :flag, :ra,
    :ipv4_network,  :ipv4_gateway, {ipv4_dns_servers: [], ipv4_pools: []},
    :ipv6_network,  :ipv6_gateway, {ipv6_dns_servers: [], ipv6_pools: []},
    :note,
  ]
  allow_nil_keys [:domain_search, :ipv4_dns_servers, :ipv6_dns_servers]

  converter :domain_search, :domain_search_data

  converter :ipv4_network, :ipv4_network_cidr
  converter :ipv4_gateway, :ipv4_gateway_address
  converter :ipv4_dns_servers, :ipv4_dns_servers_data
  converter :ipv4_pools, set: ->(record, value) {
    # record.ipv4_pools = value.map { |identifier| Ipv4Pool.new_identifier(identifier) }
    record.ipv4_pools.clear
    value.each do |identifier|
      record.ipv4_pools << Ipv4Pool.new_identifier(identifier)
    end
  }

  converter :ipv6_network, :ipv6_network_cidr
  converter :ipv6_gateway, :ipv6_gateway_address
  converter :ipv6_dns_servers, :ipv6_dns_servers_data
  converter :ipv6_pools, set: ->(record, value) {
    # record.ipv6_pools = value.map { |identifier| Ipv6Pool.new_identifier(identifier) }
    record.ipv6_pools.clear
    value.each do |identifier|
      record.ipv6_pools << Ipv6Pool.new_identifier(identifier)
    end
  }
end
