# extra database

namespace :ext_db do
  desc 'Migrate a kea database'
  task migrate_kea: :environment do
    puts 'create or replace view ipv6_reservations_alt on kea'
    Kea::KeaRecord.connection.execute <<-'SQL'.squish
      CREATE OR REPLACE VIEW ipv6_reservations_alt AS SELECT
        reservation_id,
        address,
        prefix_len,
        type AS reservation_type,
        dhcp6_iaid,
        host_id FROM ipv6_reservations;
    SQL

    puts 'create or replace view host_identifier_type_alt on kea'
    Kea::KeaRecord.connection.execute <<-'SQL'.squish
      CREATE OR REPLACE VIEW host_identifier_type_alt AS SELECT
        type AS identifier_type,
        name FROM host_identifier_type;
    SQL
  end

  desc 'Migrate a radisu database'
  task migrate_radius: :environment do
    puts 'create or replace view radcheck_alt on radius'
    Radius::RadiusRecord.connection.execute <<-'SQL'.squish
      CREATE OR REPLACE VIEW radcheck_alt AS SELECT
        id,
        username,
        attribute AS attr,
        op,
        value FROM radcheck;
    SQL

    puts 'create or replace view radreply_alt on radius'
    Radius::RadiusRecord.connection.execute <<-'SQL'.squish
      CREATE OR REPLACE VIEW radreply_alt AS SELECT
        id,
        username,
        attribute AS attr,
        op,
        value FROM radreply;
    SQL

    puts 'create or replace view radgroupcheck_alt on radius'
    Radius::RadiusRecord.connection.execute <<-'SQL'.squish
      CREATE OR REPLACE VIEW radgroupcheck_alt AS SELECT
        id,
        groupname,
        attribute AS attr,
        op,
        value FROM radgroupcheck;
    SQL

    puts 'create or replace view radgroupreply_alt on radius'
    Radius::RadiusRecord.connection.execute <<-'SQL'.squish
      CREATE OR REPLACE VIEW radgroupreply_alt AS SELECT
        id,
        groupname,
        attribute AS attr,
        op,
        value FROM radgroupreply;
    SQL
  end

  desc 'Migrate extra databases'
  task migrate: [:migrate_kea, :migrate_radius]

  desc 'Loads the seed data'
  task seed: :environment do
    groups = ['mac', 'user']
    attrs = {
      'Tunnel-Type' => '13',
      'Tunnel-Medium-Type' => '6',
    }
    groups.each do |group_name|
      attrs.each do |attr_name, value|
        puts "create or update: #{attr_name} for #{group_name} group"
        reply = Radius::Radgroupreply.find_or_initialize_by(groupname: group_name, attr: attr_name)
        reply.op = ':='
        reply.value = value
        reply.save!
      end
    end
  end

  desc 'setup'
  task setup: [:migrate, :seed]
end
