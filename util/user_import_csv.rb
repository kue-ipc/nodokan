#!/usr/bin/env rails runner

require_relative 'import_csv'

class UserImportCSV < ImportCSV
  def create(data)
    user = User.new

    user.username = data['username']
    user.email = data['email']
    user.fullname = data['fullname']
    user.role = data['role']
    user.deleted = %w[true 1 on yes].include?(data['deleted'].downcase)

    if data['auth_network'].present?
      user.auth_network = Network.find_identifier(data['auth_network'])
    end

    if data['networks'].present?
      data['networks'].split.each do |nw|
        user.networks << Network.find_identifier(nw)
      end
    end

    success = user.save
    [success, user]
  end


  def read(data)
    user = find_user(data)

    data['id'] = user.id
    data['username'] = user.username
    data['email'] = user.email
    data['fullname'] = user.fullname
    data['role'] = user.role
    date['deleted'] = user.deleted
    date['auth_network'] = user.auth_network&.identifier
    date['networks'] = user.networks.map(:identifier).join(' ')

    data['action'] = ''
    data['result'] = 'success'

    [true, user]
  end

  def update(data)
    user = find_user(data)

    user.username = data['username']
    user.email = data['email']
    user.fullname = data['fullname']
    user.role = data['role']
    user.deleted = %w[true 1 on yes].include?(data['deleted'].downcase)

    if data['auth_network'].present?
      user.auth_network = Network.find_identifier(data['auth_network'])
    else
      user.auth_network = nil
    end

    user.networks.clear
    if data['networks'].present?
      data['networks'].split.each do |nw|
        user.networks << Network.find_identifier(nw)
      end
    end

    success = user.save
    [success, user]
  end

  def delete_user(data)
    user = find_user(data)

    success = user.destroy
    [success, user]
  end

  def find_user(data)
    if data['id'].present?
      User.find(data['id'])
    elsif data['username'].present?
      User.find_by_username(data['username'])
    elsif data['email'].present?
      User.find_by_email(data['email'])
    else
      raise 'no key'
    end
  end
end

if $0 == __FILE__
  ic = UserImportCSV.new
  ic.run(ARGV)
end
