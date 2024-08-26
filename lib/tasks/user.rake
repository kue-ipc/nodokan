require "json"

namespace :user do
  desc "Sync users"
  task sync: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      puts "run job with inline queue adapter"
      Rails.application.config.active_job.queue_adapter = :inline
    end
    puts "add job queue user sync, please see log"
    UsersSyncJob.perform_later
  end

  desc "Clean users: destroy user who is deleted and has no node"
  task clean: :environment do
    puts "clean users ..."
    users = User.where(deleted: true, nodes_count: 0).destroy_all
    puts "detroied: #{users.count}"
  end

  desc "Export CSV of users"
  task export: :environment do
    file_out = "users_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_out).open("w") do |csv_out|
      puts "export csv ..."
      user_csv = ImportExport::UserCsv.new(out: csv_out, with_bom: true)
      user_csv.export
      puts "result: #{user_csv.result.to_json}"
    end
  end

  desc "Import CSV of users"
  task import: :environment do
    file_in = "users.csv"
    file_out = "users_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_in).open("r:BOM|UTF-8") do |csv_in|
      (Rails.root / "data" / file_out).open("w") do |csv_out|
        puts "import csv ..."
        user_csv = ImportExport::UserCsv.new(out: csv_out, with_bom: true)
        user_csv.import(csv_in)
        puts "result: #{user_csv.result.to_json}"
      end
    end
  end
end
