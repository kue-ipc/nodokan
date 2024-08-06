require "import_export/base_csv"

module ImportExport
  class UserCsv < BaseCsv
    def model_class
      User
    end

    ATTRS = %w(
      username email fullname
      role flag limit
      auth_network networks
    ).freeze

    def attrs
      ATTRS
    end

    # overwrite
    def row_assign(row, record, key, **_opts)
      case key
      when "networks"
        manage_ids = record.manage_network_ids
        list =
          record.use_networks.map do |network|
            if manage_ids.include?(network.id)
              "*#{network.identifier}"
            else
              network.identifier
            end
          end
        row[key] = list.join(delimiter)
      else
        super
      end
    end

    # overwrite
    def record_assign(record, row, key, **_opts)
      case key
      when "auth_network"
        record.auth_network = Network.find_identifier(row[key])
      when "networks"
        use_ids = record.use_network_ids
        row[key].split.each do |str|
          manage = str.start_with?("*")
          str = str.delete_prefix("*") if manage
          network = Network.find_identifier(str)
          record.add_use_network(network, manage: manage)
          use_ids.delete(network.id)
        end
        use_ids.each { |network_id| record.remove_use_network_id(network_id) }
      else
        super
      end
    end
  end
end
