require 'import_export/base_csv'

module ImportExport
  class NodeCSV < BaseCSV
    def model_class
      Node
    end

    def attrs
      %w[
        user
        name
        hostname
        domain
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
        nic[name]
        nic[interface_type]
        nic[network]
        nic[auth]
        nic[mac_address]
        nic[duid]
        nic[ipv4_config]
        nic[ipv4_address]
        nic[ipv6_config]
        nic[ipv6_address]
        nics
        note
      ]
    end

    def unique_attrs
      []
    end

    def nic_to_data(nic, data = {})
      data.update(
        name: nic&.name,
        interface_type: nic&.interface_type,
        network: nic&.network&.identifier,
        auth: nic&.auth,
        mac_address: nic&.mac_address,
        duid: nic&.duid,
        ipv4_config: nic&.ipv4_config,
        ipv4_address: nic&.ipv4_address,
        ipv6_config: nic&.ipv6_config,
        ipv6_address: nic&.ipv6_address,
      )
    end

    def data_to_nic(data, nic = Nic.new)
      nic.assign_attributes(
        name: data[:name],
        interface_type: data[:interface_type],
        network: Network.find_identifier(data[:network]),
        auth: data[:auth],
        mac_address: data[:mac_address],
        duid: data[:duid],
        ipv4_config: data[:ipv4_config],
        ipv4_address: data[:ipv4_address],
        ipv6_config: data[:ipv6_config],
        ipv6_address: data[:ipv6_address],
      )
      nic
    end

    def record_to_row(node, row = CSV::Row.new(header.headers, []))
      row['id'] = node.id
      row['user'] = node.user.username
      row['name'] = node.name
      row['hostname'] = node.hostname
      row['domain'] = node.domain
      row['place[area]'] = node.place&.area
      row['place[building]'] = node.place&.building
      row['place[floor]'] = node.place&.floor
      row['place[room]'] = node.place&.room
      row['hardware[device_type]'] = node.hardware&.device_type
      row['hardware[maker]'] = node.hardware&.maker
      row['hardware[product_name]'] = node.hardware&.product_name
      row['hardware[model_number]'] = node.hardware&.model_number
      row['operating_system[os_category]'] = node.operating_system&.os_category&.name
      row['operating_system[name]'] = node.operating_system&.name

      first_nic = node.nics.first
      other_nics = node.nics - [first_nic]
      nic_to_data(first_nic).each do |key, value|
        row["nic[#{key}]"] = value
      end
      row['nics'] = other_nics.presence&.map { |nic| nic_to_data(nic) }&.to_json

      row
    end

    def row_to_record(row, node = Node.new)
      node.assign_attributes(
        user: User.find_by(username: row['user']),
        name: row['name'],
        hostname: row['hostname'],
        domain: row['domain'],
        note: row['note'],
        place: Place.find_or_initialize_by(
          area: row['place[area]'] || '',
          building: row['place[building]'] || '',
          floor: row['place[floor]'].presence || 0,
          room: row['place[room]'] || '',
        ),
        hardware: Hardware.find_or_initialize_by(
          device_type:
            row['hardware[device_type]'].presence &&
            DeviceType.find_by!(name: row['hardware[device_type]']),
          maker: row['hardware[maker]'] || '',
          product_name: row['hardware[product_name]'] || '',
          model_number: row['hardware[model_number]'] || '',
        ),
        operating_system:
          row['operating_system[os_category]'].presence &&
            OperatingSystem.find_or_initialize_by(
              os_category: OsCategory.find_by!(name: row['operating_system[os_category]']),
              name: row['operating_system[name]'] || '',
            ),
      )

      first_nic = node.nics.first
      other_nics = node.nics - [first_nic]
      new_nics = []

      if row['nic[interface_type]'].present?
        first_nic ||= Nic.new(number: 1)
        first_data = {
          name: row['nic[name]'],
          interface_type: row['nic[interface_type]'],
          network: row['nic[network]'],
          auth: %w[true 1 on yes].include?(row['nic[auth]']&.downcase),
          mac_address: row['nic[mac_address]'],
          duid: row['nic[duid]'],
          ipv4_config: row['nic[ipv4_config]'].presence || 'disabled',
          ipv4_address: row['nic[ipv4_address]'],
          ipv6_config: row['nic[ipv6_config]'].presence || 'disabled',
          ipv6_address: row['nic[ipv6_address]'],
        }
        data_to_nic(first_data, first_nic)
        new_nics << first_nic
      end

      if row['nics'].present?
        data_nics = JSON.parse(row['nics'], symbolize_names: true)
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
