require 'import_export/base.csv'

module ImportExport
  class NodeCSV < BaseCSV
    def model_class
      User
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
        note
      ]
    end

    def unique_attrs
      []
    end

    def record_to_row(node, row)
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
      row['operating_system[os_category]'] = node.operating_system&.os_category
      row['operating_system[name]'] = node.operating_system&.name
      case node.nics.count
      when 0
        row['nic[name]'] = nil
        row['nic[interface_type]'] = nil
        row['nic[network]'] = nil
        row['nic[auth]'] = nil
        row['nic[mac_address]'] = nil
        row['nic[duid]'] = nil
        row['nic[ipv4_config]'] = nil
        row['nic[ipv4_address]'] = nil
        row['nic[ipv6_config]'] = nil
        row['nic[ipv6_address]'] = nil
      when 1
        row['nic[name]'] = node.nics.first&.name
        row['nic[interface_type]'] = node.nics.first&.interface_type
        row['nic[network]'] = node.nics.first&.network&.identifier
        row['nic[auth]'] = node.nics.first&.auth
        row['nic[mac_address]'] = node.nics.first&.mac_address
        row['nic[duid]'] = node.nics.first&.duid
        row['nic[ipv4_config]'] = node.nics.first&.ipv4_config
        row['nic[ipv4_address]'] = node.nics.first&.ipv4_address
        row['nic[ipv6_config]'] = node.nics.first&.ipv6_config
        row['nic[ipv6_address]'] = node.nics.first&.ipv6_address
      else
        row['nic[name]'] = node.nics.first&.name
        row['nic[interface_type]'] = node.nics.first&.interface_type
        row['nic[network]'] = node.nics.first&.network&.identifier
        row['nic[auth]'] = node.nics.first&.auth
        row['nic[mac_address]'] = node.nics.first&.mac_address
        row['nic[duid]'] = node.nics.first&.duid
        row['nic[ipv4_config]'] = node.nics.first&.ipv4_config
        row['nic[ipv4_address]'] = node.nics.first&.ipv4_address
        row['nic[ipv6_config]'] = node.nics.first&.ipv6_config
        row['nic[ipv6_address]'] = node.nics.first&.ipv6_address
      end
      row
    end

    def row_to_record(row, node)
      node.assign_attributes(
        user: User.find_by(usnername: data['user']),
        name: data['name'],
        hostname: data['hostname'],
        domain: data['domain'],
        note: data['note'],
        place: Place.find_or_initialize_by(
          area: data['place[area]'] || '',
          building: data['place[building]'] || '',
          floor: data['place[floor]'].presence || 0,
          room: data['place[room]'] || '',
        ),
        hardware: data['hardware[device_type]'].presence ||
                  data['hardware[product_name]'].presence ||
                  Hardware.find_or_initialize_by(
                    device_type: DeviceType.find_by(name: data['hardware[device_type]']),
                    maker: data['hardware[maker]'] || '',
                    product_name: data['hardware[product_name]'] || '',
                    model_number: data['hardware[model_number]'] || '',
                  ),
        operating_system: data['operating_system[os_category]'].presence ||
                          OperatingSystem.find_or_initialize_by(
                            os_category: Opreting_system.find_by(name: data['operating_system[os_category]']),
                            name: data['operating_system[name]'] || '',
                          ),
      )

      if data['nic[network]'].present?
        if data['nic[network]'] =~ /^\#(\d+)$/i
          network = Network.find($1)
        elsif data['nic[network]'] =~ /^v(\d+)$/i
          network = Network.find_by_vlan($1)
        else
          raise "invalid network: #{nic[]}"
        end

        if network.nil?
          raise "no network: #{data['nic[network]']}"
        end

        node.nics <<
          Nic.new(
            network: network,
            interface_type: data['nic[interface_type]'].presence || 'unknown',
            name: data['nic[name]'],
            auth: %w[true 1 on yes].include?(data['nic[auth]']&.downcase),
            mac_address: data['nic[mac_address]'],
            duid: data['nic[duid]'],
            ipv4_config: data['nic[ipv4_config]'].presence || 'disabled',
            ipv4_address: data['nic[ipv4_address]'],
            ipv6_config: data['nic[ipv6_config]'].presence || 'disabled',
            ipv6_address: data['nic[ipv6_address]'],
          )
      end

      node
    end

    def create(data)
      node = Node.new

      node.user = User.find_by_username(data['user'])
      node.name = data['name']
      node.hostname = data['hostname']
      node.domain = data['domain']
      node.note = data['note']

      node.place = Place.find_or_initialize_by(
        area: data['place[area]'] || '',
        building: data['place[building]'] || '',
        floor: data['place[floor]'].presence || 0,
        room: data['place[room]'] || '',
      )

      node.hardware = if data['hardware[device_type]'].present? ||
                         data['hardware[product_name]']
          Hardware.find_or_initialize_by(
            device_type: DeviceType.find_by(name: data['hardware[device_type]']),
            maker: data['hardware[maker]'] || '',
            product_name: data['hardware[product_name]'] || '',
            model_number: data['hardware[model_number]'] || '',
          )
        end

      node.operating_system = if data['operating_system[os_category]'].present?
          OperatingSystem.find_or_initialize_by(
            os_category: Opreting_system.find_by(name: data['operating_system[os_category]']),
            name: data['operating_system[name]'] || '',
          )
        end

      if data['nic[network]'].present?
        if data['nic[network]'] =~ /^\#(\d+)$/i
          network = Network.find($1)
        elsif data['nic[network]'] =~ /^v(\d+)$/i
          network = Network.find_by_vlan($1)
        else
          raise "invalid network: #{nic[]}"
        end

        if network.nil?
          raise "no network: #{data['nic[network]']}"
        end

        node.nics <<
          Nic.new(
            network: network,
            interface_type: data['nic[interface_type]'].presence || 'unknown',
            name: data['nic[name]'],
            auth: %w[true 1 on yes].include?(data['nic[auth]']&.downcase),
            mac_address: data['nic[mac_address]'],
            duid: data['nic[duid]'],
            ipv4_config: data['nic[ipv4_config]'].presence || 'disabled',
            ipv4_address: data['nic[ipv4_address]'],
            ipv6_config: data['nic[ipv6_config]'].presence || 'disabled',
            ipv6_address: data['nic[ipv6_address]'],
          )
      end

      success = node.save
      [success, node]
    end
  end
end
