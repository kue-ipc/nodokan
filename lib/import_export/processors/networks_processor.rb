require "ipaddr"
require "json"

require "import_export/processors/application_processor"

module ImportExport
  module Processors
    class NetworksProcessor < ApplicationProcessor
      model ::Network
      keys(
        :name,
        :vlan,
        :flag,
        :ra,
        :ipv4_network,
        :ipv4_gateway,
        :ipv6_network,
        :ipv6_gateway,
        :domain,
        :note,
        domain_search: [],
        ipv4_dns_servers: [],
        ipv6_dns_servers: [],
        ipv4_pools: [],
        ipv6_pools: [])

      convert_map({
        ipv4_network: :ipv4_network_cidr,
        ipv4_gateway: :ipv4_gateway_address,
        ipv6_network: :ipv6_network_cidr,
        ipv6_gateway: :ipv6_gateway_address,
        ipv4_pools: {
          set: ->(record, value) {
            record.ipv4_pools = value.map { |pl| Ipv4Pool.new_identifier(pl) }
          },
        },
        ipv6_pools: {
          set: ->(record, value) {
            record.ipv6_pools = value.map { |pl| Ipv6Pool.new_identifier(pl) }
          },
        },
      })
    end
  end
end
