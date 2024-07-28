require "import_export/base_csv"

module ImportExport
  class NodeCsv < BaseCsv
    def model_class
      Node
    end

    ATTRS =
      %w(
        user name fqdn type flag
        host
        components
        place[area]
        place[building]
        place[floor]
        place[room]
        hardware[device_type]
        hardware[maker]
        hardware[product_name]
        hardware[model_number]
        operating_system[os_category]
        operating_system[name]
        duid
        nic[number]
        nic[name]
        nic[interface_type]
        nic[network]
        nic[flag]
        nic[mac_address]
        nic[ipv4_config]
        nic[ipv4_address]
        nic[ipv6_config]
        nic[ipv6_address]
        note
      )

    def attrs
      ATTRS
    end

    def nic_to_data(nic, data = {})
      return data if nic.nil?

      data.update(
        number: nic.number,
        name: nic.name,
        interface_type: nic.interface_type,
        network: value_to_csv(nic.network),
        flag: nic.flag,
        mac_address: nic.mac_address,
        ipv4_config: nic.ipv4_config,
        ipv4_address: nic.ipv4_address,
        ipv6_config: nic.ipv6_config,
        ipv6_address: nic.ipv6_address)
    end

    def data_to_nic(data, nic = Nic.new)
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

    def split_row_record(record)
      record.nic_ids.presence || [nil]
    end

    def record_to_row(node, target: nil, keys: attrs, **opts)
      row = super(node,
        keys: keys - %w(
          type
          nic[number]
          nic[name]
          nic[interface_type]
          nic[network]
          nic[flag]
          nic[mac_address]
          nic[ipv4_config]
          nic[ipv4_address]
          nic[ipv6_config]
          nic[ipv6_address]
        ), **opts)

      row["type"] = node.node_type

      if target
        nic_to_data(Nic.find(target)).each do |key, value|
          row["nic[#{key}]"] = value
        end
      end

      row
    end

    def row_to_record(row, node = Node.new)
      node.assign_attributes(
        user: User.find_by(username: row["user"]),
        name: row["name"],
        flag: row["flag"],
        hostname: row["hostname"],
        domain: row["domain"],
        duid: row["duid"],
        note: row["note"],
        place: Place.find_or_initialize_by(
          area: row["place[area]"] || "",
          building: row["place[building]"] || "",
          floor: row["place[floor]"].presence || 0,
          room: row["place[room]"] || ""),
        hardware: Hardware.find_or_initialize_by(
          device_type:
            row["hardware[device_type]"].presence &&
            DeviceType.find_by!(name: row["hardware[device_type]"]),
          maker: row["hardware[maker]"] || "",
          product_name: row["hardware[product_name]"] || "",
          model_number: row["hardware[model_number]"] || ""),
        operating_system:
          row["operating_system[os_category]"].presence &&
            OperatingSystem.find_or_initialize_by(
              os_category:
                OsCategory.find_by!(name: row["operating_system[os_category]"]),
              name: row["operating_system[name]"] || ""))

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
  end
end
