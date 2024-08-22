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

      # override
      def get_param(record, key)
        case key
        in :ipv4_network
          record.ipv4_network_cidr
        in :ipv4_gateway
          record.ipv4_gateway_address
        in :ipv6_network
          record.ipv6_network_cidr
        in :ipv6_gateway
          record.ipv6_gateway_address
        else
          super
        end
      end

      # override
      def record_assign(record, row, key, **_opts)
        case key
        when "ipv4_network"
          record.ipv4_network_cidr = row[key]
        when "ipv6_network"
          record.ipv6_network_cidr = row[key]
        when "ipv4_pools"
          record.ipv4_pools =
            row[key].split.map { |pl| Ipv4Pool.new_identifier(pl) }
        when "ipv6_pools"
          record.ipv6_pools =
            row[key].split.map { |pl| Ipv6Pool.new_identifier(pl) }
        when "ipv4_gateway"
          record.ipv4_gateway_address = row[key]
        when "ipv6_gateway"
          record.ipv6_gateway_address = row[key]
        else
          super
        end
      end
    end
  end
end
