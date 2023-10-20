namespace :kea do
  desc "Migration kea database"
  task migrate: :environment do
    puts "create or replace view ipv6_reservations_alt on kea"
    Kea::KeaRecord.connection.execute <<-SQL.squish
      CREATE OR REPLACE VIEW ipv6_reservations_alt AS SELECT
        reservation_id,
        address,
        prefix_len,
        type AS reservation_type,
        dhcp6_iaid,
        host_id FROM ipv6_reservations;
    SQL

    puts "create or replace view host_identifier_type_alt on kea"
    Kea::KeaRecord.connection.execute <<-SQL.squish
      CREATE OR REPLACE VIEW host_identifier_type_alt AS SELECT
        type AS identifier_type,
        name FROM host_identifier_type;
    SQL
  end

  desc "Setup keas database"
  task setup: :migrate

  desc "Check kea record"
  task check: :environment do
    if Rails.env.production?
      puts "add job queue kea check, please see log"
      KeaReservationCheckAllJob.perform_later
      KeaSubnetCheckAllJob.perform_later
    else
      puts "run job queue kea check, please wait..."
      KeaReservationCheckAllJob.perform_now
      KeaSubnetCheckAllJob.perform_now
    end
  end
end
