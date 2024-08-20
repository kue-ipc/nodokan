namespace :kea do
  desc "Migration kea database"
  task migrate: :environment do
    # puts "create or replace view ipv6_reservations_alt on kea"
    # Kea::KeaRecord.connection.execute <<-SQL.squish
    #   CREATE OR REPLACE VIEW ipv6_reservations_alt AS SELECT
    #     reservation_id,
    #     address,
    #     prefix_len,
    #     type AS reservation_type,
    #     dhcp6_iaid,
    #     host_id FROM ipv6_reservations;
    # SQL

    # puts "create or replace view host_identifier_type_alt on kea"
    # Kea::KeaRecord.connection.execute <<-SQL.squish
    #   CREATE OR REPLACE VIEW host_identifier_type_alt AS SELECT
    #     type AS identifier_type,
    #     name FROM host_identifier_type;
    # SQL

    puts "drop view ipv6_reservations_alt on kea"
    Kea::KeaRecord.connection.execute <<-SQL.squish
      DROP VIEW IF EXISTS ipv6_reservations_alt;
    SQL

    puts "drop view host_identifier_type_alt on kea"
    Kea::KeaRecord.connection.execute <<-SQL.squish
      DROP VIEW IF EXISTS host_identifier_type_alt;
    SQL
  end

  desc "Setup kea database"
  task setup: :migrate

  desc "Check kea record"
  task check: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      puts "run job with inline queue adapter"
      Rails.application.config.active_job.queue_adapter = :inline
    end
    puts "add job queue kea check, please see log"
    KeaReservationCheckAllJob.perform_later
    KeaSubnetCheckAllJob.perform_later
  end
end
