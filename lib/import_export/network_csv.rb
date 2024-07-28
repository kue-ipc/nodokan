require "import_export/base_csv"
require "ipaddr"
require "json"

module ImportExport
  class NetworkCsv < BaseCsv
    def model_class
      Network
    end

    ATTRS = %w(
      name vlan flag ra
      ipv4_network ipv4_gateway ipv4_pools
      ipv6_network ipv6_gateway ipv6_pools
      note
    ).freeze

    def attrs
      ATTRS
    end

    # overwrite
    def delimiter
      "\n"
    end

    # overwrite
    def row_assign(row, record, key)
      case key
      when "ipv4_network"
        row[key] = record.ipv4_network_cidr
      when "ipv6_network"
        row[key] = record.ipv6_network_cidr
      else
        super
      end
    end

    # overwrite
    def record_assign(record, row, key)
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
      else
        super
      end
    end
  end
end
