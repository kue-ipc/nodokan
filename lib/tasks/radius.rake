namespace :radius do
  desc "Migrate radisu database"
  task migrate: :environment do
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
    groups.each do |group_name|
      attrs.each do |attr_name, value|
        puts "create or update: #{attr_name} for #{group_name} group"
        reply = Radius::Radgroupreply.find_or_initialize_by(groupname: group_name, attr: attr_name)
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
    if Rails.env.production?
      puts "add job queue radius check, please see log"
      RadiusCheckAllJob.perform_later
    else
      puts "run job queue radius check, please wait..."
      RadiusCheckAllJob.perform_now
    end
  end

  desc "Compress radpostauth"
  task compress: :environment do
    if Rails.env.production?
      puts "add job queue commpress radpostauths, please see log"
      RadiusCompressJob.perform_later
    else
      puts "run job queue commpress radpostauths, please wait..."
      RadiusCompressJob.perform_now
    end
  end
end
