#!/usr/bin/env rails runner

require 'csv'
require 'fileutils'
require 'logger'
require 'json'

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

def create_user(data)
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

  if user.save
    data['id'] = user.id
    data['action'] = ''
    data['result'] = 'success'
    true
  else
    data['result'] = 'failure'
    data['message'] = user.errors.to_json
    false
  end
end


def read_user(data)
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

  true
end

def update_user(data)
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

  if user.save
    data['id'] = user.id
    data['action'] = ''
    data['result'] = 'success'
    true
  else
    data['result'] = 'failure'
    data['message'] = user.errors.to_json
    false
  end
end

def delete_user(data)
  user = find_user(data)

  if user.destory
    data['id'] = user.id
    data['action'] = ''
    data['result'] = 'success'
    true
  else
    data['result'] = 'failure'
    data['message'] = user.errors.to_json
    false
  end
end

if $0 == __FILE__
  csv_file = ARGV[0]
  if csv_file.nil?
    warn "USAGE: rails runner #{$0} CSV_FILE"
    exit(1)
  end

  backup_file = "#{csv_file}.#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}"
  tmp_file = "#{csv_file}.tmp"
  logger = Logger.new($stderr)

  csv_datas = CSV.read(csv_file, encoding: 'BOM|UTF-8', headers: :first_row)

  File.open(tmp_file, 'wb:UTF-8') do |io|
    io.write "\u{feff}"
    io.puts csv_datas.headers.to_csv
    csv_datas.each.with_index do |data, idx|
      data['result'] = ''
      data['message'] = ''

      case data['action'].first.upcase
      when ''
        data['result'] = 'skip'
      when 'C'
        create_user(data)
      when 'R'
        read_user(data)
      when 'U'
        update_user(data)
      when 'D'
        delete_user(data)
      else
        raise "unknown id: #{data['id']}"
      end
    rescue StandardError => e
      data['result'] = "error"
      data['message'] = e.message
    ensure
      logger.info(
        "#{idx}: [#{data['result']}] #{data['id']}: #{data['message']}")
      io.puts data.to_csv
    end
  end
  FileUtils.move(csv_file, backup_file)
  FileUtils.move(tmp_file, csv_file)
end
