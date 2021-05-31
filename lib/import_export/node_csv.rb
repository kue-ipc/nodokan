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
      row['user'] = node.user.username,
      row['name'] = node.name,
      row[''] = node.hostname,
      row[''] = node.domain,
      row[''] = node.place&.area,
      row[''] = node.place&.building,
      row[''] = node.place&.floor,
      row[''] = node.place&.room,
      row[''] = node.hardware&.device_type,
      row[''] = node.hardware&.maker,
      row[''] = node.hardware&.product_name,
      row[''] = node.hardware&.model_number,
      row[''] = node.operating_system&.os_category,
      row[''] = node.operating_system&.name,
      row[''] = node.nics.first&.name,
      row[''] = node.nics.first&.interface_type,
      row[''] = node.nics.first&.network&.identifier,
      row[''] = node.nics.first&.auth,
      row[''] = node.nics.first&.mac_address,
      row[''] = node.nics.first&.duid,
      row[''] = node.nics.first&.ipv4_config,
      row[''] = node.nics.first&.ipv4_address,
      row[''] = node.nics.first&.ipv6_config,
      row[''] = node.nics.first&.ipv6_address,
      row[''] = node.note

      row['username'] = user.username
      row['email'] = user.email
      row['fullname'] = user.fullname
      row['role'] = user.role
      row['deleted'] = user.deleted
      row['auth_network'] = user.auth_network&.identifier
      row['networks'] = user.networks.map(&:identifier).join(' ').presence
      row
    end

    def row_to_record(row, user)
      user.assign_attributes(
        username: row['username'],
        email: row['email'],
        fullname: row['fullname'],
        role: row['role'],
        deleted: %w[true 1 on yes].include?(row['deleted'].downcase),
        auth_network: Network.find_identifier(row['auth_network']),
      )
      user.clear_use_networks
      row['networks']&.split&.each do |nw|
        user.add_use_network(Network.find_identifier(nw))
      end
      user
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
        room: data['place[room]'] || ''
      )
    
      node.hardware = 
        if data['hardware[device_type]'].present? ||
            data['hardware[product_name]']
          Hardware.find_or_initialize_by(
            device_type: DeviceType.find_by(name: data['hardware[device_type]']),
            maker: data['hardware[maker]'] || '',
            product_name: data['hardware[product_name]'] || '',
            model_number: data['hardware[model_number]'] || ''
          )
        end
    
      node.operating_system =
        if data['operating_system[os_category]'].present?
          OperatingSystem.find_or_initialize_by(
            os_category: Opreting_system.find_by(name: data['operating_system[os_category]']),
            name: data['operating_system[name]'] || ''
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
            auth:
              %w[true 1 on yes].include?(data['nic[auth]']&.downcase),
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
