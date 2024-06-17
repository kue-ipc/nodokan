require "json"

require "import_export/user_csv"

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
    csv_file = Rails.root / "data" / "users.csv"
    puts "export csv ..."
    results = ImportExport::UserCsv.new(csv_file, logger: Rails.logger).export
    puts results.to_json
  end

  desc "Import CSV of users"
  task import: :environment do
    csv_file = Rails.root / "data" / "users.csv"
    puts "import csv ..."
    results = ImportExport::UserCsv.new(csv_file, logger: Rails.logger).import
    puts results.to_json
  end
end
