require "import_export/base_csv"

module ImportExport
  class NodeCsv < BaseCsv
    def model_class
      Node
    end

    ATTRS =
      %w(
        user name fqdn type flag
        host components
        place[area] place[building] place[floor] place[room]
        hardware[device_type] hardware[maker] hardware[product_name]
        hardware[model_number]
        operating_system[os_category] operating_system[name]
        duid
        nic[number] nic[name] nic[interface_type] nic[network]
        nic[flag] nic[mac_address]
        nic[ipv4_config] nic[ipv4_address]
        nic[ipv6_config] nic[ipv6_address]
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
    def split_row_record(record)
      record.nics.map { |nic| {nic: nic} }.presence || [{nic: nil}]
    end

    # overwrite
    def row_assign(row, record, key, nic: nil, **_opts)
      case key
      when "type"
        row[key] = record.node_type
      when "nic[number]", "nic[name]", "nic[interface_type]", "nic[network]",
          "nic[flag]", "nic[mac_address]",
          "nic[ipv4_config]", "nic[ipv4_address]",
          "nic[ipv6_config]", "nic[ipv6_address]"
        if nic
          row[key] =
            value_to_field(nic.__send__(key_to_list(key).last))
        end
      else
        super
      end
    end

    # overwrite
    def record_assign(record, row, key, **_opts)
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
    def row_to_record(row, record: model_class.new, keys: attrs, **opts)
      record.user = @user if record.new_record? && !@user.nil && !@user.admin?

      super(row, record: record, keys: keys.slice(%w(
        user name fqdn type flag
        host components
        duid note
      )), **opts)

      # TODO: ここから
      # FIXME: 空白は上書きではなく、既存を取ること
      record.place = Place.find_or_initialize_by(
        area: row["place[area]"] || "",
        building: row["place[building]"] || "",
        floor: row["place[floor]"].presence || 0,
        room: row["place[room]"] || "")

      record.hardware = Hardware.find_or_initialize_by(
        device_type:
          row["hardware[device_type]"].presence &&
          DeviceType.find_by!(name: row["hardware[device_type]"]),
        maker: row["hardware[maker]"] || "",
        product_name: row["hardware[product_name]"] || "",
        model_number: row["hardware[model_number]"] || "")

      if row["operating_system[os_category]"].presence
        record.operating_system = OperatingSystem.find_or_initialize_by(
          os_category:
            OsCategory.find_by!(name: row["operating_system[os_category]"]),
          name: row["operating_system[name]"] || "")
      end

      case row["nic[number]"]&.strip
      when nil, ""
        create_nic
      when /\A\d+\z/
        nic_number = row["nic[number]"].strip.to_i
      when /\A!\d+\z/
        nic_number = row["nic[number]"].strip.delete_prefix("!").to_i
      else
        row["[result]"] = :failed
        row["[message]"] = I18n.t("errors.messages.invalid_id_field")
      end

      first_nic = node.nics.first
      other_nics = node.nics - [first_nic]
      new_nics = []

      if row["nic[interface_type]"].present?
        first_nic ||= Nic.new(number: 1)
        first_data = {
          name: row["nic[name]"],
          interface_type: row["nic[interface_type]"],
          network: row["nic[network]"],
          flag: row["nic[flag]"],
          mac_address: row["nic[mac_address]"],
          ipv4_config: row["nic[ipv4_config]"].presence || "disabled",
          ipv4_address: row["nic[ipv4_address]"],
          ipv6_config: row["nic[ipv6_config]"].presence || "disabled",
          ipv6_address: row["nic[ipv6_address]"],
        }
        data_to_nic(first_data, first_nic)
        new_nics << first_nic
      end

      if row["nics"].present?
        data_nics = JSON.parse(row["nics"], symbolize_names: true)
        data_nics.each_with_index do |data, idx|
          nic = other_nics[idx] || Nic.new(number: idx + 2)
          data_to_nic(data, nic)
          new_nics << nic
        end
      end

      # 一旦保存しないとidがなくてうまくいかない。
      node.save! if node.id.nil?
      node.nics = new_nics

      node
    end

    def record_assign(record, row, key, **_opts)
      case key
      when "user"
        if @user.nil || @user.admin?
          record.user = User.find_by(username: row["user"])
        end
      when "type"
      when "host"
      when "components"
      else
        super
      end
    end

    private def data_to_nic(data, nic = Nic.new)
      nic.assign_attributes(
        name: data[:name],
        interface_type: data[:interface_type],
        network: Network.find_identifier(data[:network]),
        flag: data[:flag],
        mac_address: data[:mac_address],
        ipv4_config: data[:ipv4_config],
        ipv4_address: data[:ipv4_address],
        ipv6_config: data[:ipv6_config],
        ipv6_address: data[:ipv6_address])
      nic
    end
  end
end
