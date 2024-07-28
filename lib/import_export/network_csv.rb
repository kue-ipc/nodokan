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
    # def row_to_record(row, network)
    #   network.assign_attributes(
    #     name: row["name"],
    #     flag: row["flag"],
    #     vlan: row["vlan"].presence&.to_i)

    #   if row["ipv4_network"].present?
    #     address, mask = row["ipv4_network"].split("/")
    #     network.ipv4_network_address = address
    #     network.ipv4_prefix_length = mask
    #   else
    #     network.ipv4_network_address = nil
    #     network.ipv4_prefix_length = 0
    #   end

    #   network.ipv4_gateway_address = row["ipv4_gateway"].presence

    #   network.ipv4_pools.clear
    #   if row["ipv4_pools"].present?
    #     row["ipv4_pools"].split.each do |pl|
    #       network.ipv4_pools << Ipv4Pool.new_identifier(pl)
    #     end
    #   end

    #   if row["ipv6_network"].present?
    #     address, mask = row["ipv6_network"].split("/")
    #     network.ipv6_network_address = address
    #     network.ipv6_prefix_length = mask
    #   else
    #     network.ipv6_network_address = nil
    #     network.ipv6_prefix_length = 0
    #   end

    #   network.ipv6_gateway_address = row["ipv6_gateway"].presence

    #   network.ipv6_pools.clear
    #   if row["ipv6_pools"].present?
    #     row["ipv6_pools"].split.each do |pl|
    #       network.ipv6_pools << Ipv6Pool.new_identifier(pl)
    #     end
    #   end
    #   network
    # end
  end
end
