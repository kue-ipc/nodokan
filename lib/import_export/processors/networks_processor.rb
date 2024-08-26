require "ipaddr"
require "json"

require "import_export/processors/application_processor"

module ImportExport
  module Processors
    class NetworksProcessor < ApplicationProcessor
      class_name "Network"

      params_permit(
        :name, :vlan, :flag, :ra,
        :domain, {domain_search: []},
        :ipv4_network,  :ipv4_gateway, {ipv4_dns_servers: [], ipv4_pools: []},
        :ipv6_network,  :ipv6_gateway, {ipv6_dns_servers: [], ipv6_pools: []},
        :note)

      converter :domain_search, :domain_search_data

      converter :ipv4_network, :ipv4_network_cidr
      converter :ipv4_gateway, :ipv4_gateway_address
      converter :ipv4_dns_servers, :ipv4_dns_servers_data
      converter :ipv4_pools, set: ->(record, value) {
        record.ipv4_pools = value.map(&Ipv4Pool.method(:new_identifier))
      }

      converter :ipv6_network, :ipv6_network_cidr
      converter :ipv6_gateway, :ipv6_gateway_address
      converter :ipv6_dns_servers, :ipv6_dns_servers_data
      converter :ipv6_pools, set: ->(record, value) {
        record.ipv6_pools = value.map(&Ipv6Pool.method(:new_identifier))
      }
    end
  end
end
