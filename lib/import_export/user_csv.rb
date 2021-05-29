require 'import_export/base_csv'

module ImportExport
  class UserCSV < BaseCSV
    def model_class
      User
    end

    def attrs
      %w[
        username
        email
        fullname
        role
        deleted
        auth_network
        networks
      ]
    end

    def unique_attrs
      %w[
        username
        email
      ]
    end

    def record_to_row(user, row)
      row['id'] = user.id
      row['username'] = user.username
      row['email'] = user.email
      row['fullname'] = user.fullname
      row['role'] = user.role
      row['deleted'] = user.deleted
      row['auth_network'] = user.auth_network&.identifier
      row['networks'] = user.networks.map(&:identifier).join(' ').presence
      row
    end

    def row_to_record(row)
      raise NotImplementedError
    end

    def create(row)
      user = User.new(
        username: row['username'],
        email: row['email'],
        fullname: row['fullname'],
        role: row['role'],
        deleted: %w[true 1 on yes].include?(row['deleted'].downcase),
        auth_network: Network.find_identifier(row['auth_network']),
      )

      row['networks']&.split&.each do |nw|
        user.add_use_network(Network.find_identifier(nw))
      end

      if user.save
        row['id'] = user.id
        [true, nil]
      else
        [false, user.errors.to_json]
      end
    end

    def update(row)
      user = find(row)

      return [false, 'Not found.'] unless user

      row['id'] = user.id

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

      if user.save
        [true, nil]
      else
        [false, user.errors.to_json]
      end
    end
  end
end
