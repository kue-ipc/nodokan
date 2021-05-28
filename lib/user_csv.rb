require 'import_export_csv'

class UserCSV < ImportExportCSV
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

  def find(row)
    if row['id'].present?
      User.find(row['id'])
    elsif row['username'].present?
      User.find_by(username: row['username'])
    elsif row['email'].present?
      User.find_by(email: row['email'])
    end
  end

  def record_to_row(record, row)
    row['id'] = record.id
    row['username'] = record.username
    row['email'] = record.email
    row['fullname'] = record.fullname
    row['role'] = record.role
    row['deleted'] = record.deleted
    row['auth_network'] = record.auth_network&.identifier
    row['networks'] = record.networks.map(&:identifier).join(' ').presence
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
