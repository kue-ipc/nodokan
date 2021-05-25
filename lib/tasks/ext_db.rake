namespace :ext_db do
  desc "migrate"
  task migrate: :environment do
    Kea::KeaRecord.connection.execute <<~'SQL'.squish
      CREATE OR REPLACE VIEW ipv6_reservations_alt AS SELECT
        reservation_id,
        address,
        prefix_len,
        type AS reservation_type,
        dhcp6_iaid,
        host_id FROM ipv6_reservations;
    SQL

    Kea::KeaRecord.connection.execute <<~'SQL'.squish
      CREATE OR REPLACE VIEW host_identifier_type_alt AS SELECT
        type AS identifier_type,
        name FROM host_identifier_type;
    SQL

    Radius::RadiusRecord.connection.execute <<~'SQL'.squish
      CREATE OR REPLACE VIEW radcheck_alt AS SELECT
        id,
        username,
        attribute AS attr,
        op,
        value FROM radcheck;
    SQL

    Radius::RadiusRecord.connection.execute <<~'SQL'.squish
      CREATE OR REPLACE VIEW radreply_alt AS SELECT
        id,
        username,
        attribute AS attr,
        op,
        value FROM radreply;
    SQL

    Radius::RadiusRecord.connection.execute <<~'SQL'.squish
      CREATE OR REPLACE VIEW radgroupcheck_alt AS SELECT
        id,
        groupname,
        attribute AS attr,
        op,
        value FROM radgroupcheck;
    SQL

    Radius::RadiusRecord.connection.execute <<~'SQL'.squish
      CREATE OR REPLACE VIEW radgroupreply_alt AS SELECT
        id,
        groupname,
        attribute AS attr,
        op,
        value FROM radgroupreply;
    SQL
  end

  desc "Loads the seed data"
  task seed: :environment do
    ['mac', 'user'].each do |name|
      Radius::Radgroupreply.find_or_initialize_by(
        groupname: name,
        attr: 'Tunnel-Type',
      ).tap do |radgroupreply|
        radgroupreply.op = ':='
        radgroupreply.value = '13'
        radgroupreply.save!
        Rails.logger.info("create or update: Tunnel-Type for #{name} group")
      end

      Radius::Radgroupreply.find_or_initialize_by(
        groupname: name,
        attr: 'Tunnel-Medium-Type',
      ).tap do |radgroupreply|
        radgroupreply.op = ':='
        radgroupreply.value = '6'
        radgroupreply.save!
        Rails.logger.info(
          "create or update: Tunnel-Medium-Type for #{name} group")
      end
    end
  end

  desc "setup"
  task setup: [:migrate, :seed]

end
