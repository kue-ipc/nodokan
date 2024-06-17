namespace :radius do
  desc "Migrate radisu database"
  task migrate: :environment do
    puts "create or replace view nas_alt on radius"
    Radius::RadiusRecord.connection.execute <<-SQL.squish
      CREATE OR REPLACE VIEW nas_alt AS SELECT
        id,
        nasname,
        shortname,
        type AS nas_type,
        ports,
        secret,
        server,
        community,
        description FROM nas;
    SQL

    puts "create or replace view radcheck_alt on radius"
    Radius::RadiusRecord.connection.execute <<-SQL.squish
      CREATE OR REPLACE VIEW radcheck_alt AS SELECT
        id,
        username,
        attribute AS attr,
        op,
        value FROM radcheck;
    SQL

    puts "create or replace view radreply_alt on radius"
    Radius::RadiusRecord.connection.execute <<-SQL.squish
      CREATE OR REPLACE VIEW radreply_alt AS SELECT
        id,
        username,
        attribute AS attr,
        op,
        value FROM radreply;
    SQL

    puts "create or replace view radgroupcheck_alt on radius"
    Radius::RadiusRecord.connection.execute <<-SQL.squish
      CREATE OR REPLACE VIEW radgroupcheck_alt AS SELECT
        id,
        groupname,
        attribute AS attr,
        op,
        value FROM radgroupcheck;
    SQL

    puts "create or replace view radgroupreply_alt on radius"
    Radius::RadiusRecord.connection.execute <<-SQL.squish
      CREATE OR REPLACE VIEW radgroupreply_alt AS SELECT
        id,
        groupname,
        attribute AS attr,
        op,
        value FROM radgroupreply;
    SQL
  end

  desc "Loads the seed data for radius"
  task seed: :environment do
    groups = ["mac", "user"]
    attrs = {
      "Tunnel-Type" => "13",
      "Tunnel-Medium-Type" => "6",
    }
    groups.each do |groupname|
      attrs.each do |attr, value|
        puts "create or update: #{attr} for #{groupname} group"
        # NOTE: テーブルがVIEWであるため、作成時に `id: nil` を設定する必要がある。
        #       find_or_initilaize_byは使用できない。
        reply =
          Radius::Radgroupreply.find_by(groupname: groupname, attr: attr) ||
          Radius::Radgroupreply.new(id: nil, groupname: groupname, attr: attr)
        reply.op = ":="
        reply.value = value
        reply.save!
      end
    end
  end

  desc "Setup radius database"
  task setup: [:migrate, :seed]

  desc "Check radius record"
  task check: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      puts "run job with inline queue adapter"
      Rails.application.config.active_job.queue_adapter = :inline
    end
    puts "add job queue radius check, please see log"
    RadiusCheckAllJob.perform_later
  end

  desc "Clean radius record"
  task clean: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      puts "run job with inline queue adapter"
      Rails.application.config.active_job.queue_adapter = :inline
    end
    puts "add job queue clean radius, please see log"
    RadiusCleanJob.perform_later
  end
end
