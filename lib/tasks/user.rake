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

  desc "Import CSV of users"
  task import: :environment do
    name = "user"
    processor = ImportExport::Processors::UsersProcessor.new
    file_in = "#{name}.csv"
    file_out = "#{name}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_in).open("r:BOM|UTF-8") do |csv_in|
      (Rails.root / "data" / file_out).open("w") do |csv_out|
        puts "import csv ..."
        batch = ImportExport::Csv.new(processor, out: csv_out, with_bom: true)
        batch.import(csv_in)
        puts "result: #{batch.result.to_json}"
      end
    end
  end

  desc "Export CSV of users"
  task export: :environment do
    name = "user"
    processor = ImportExport::Processors::UsersProcessor.new
    file_out = "#{name}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_out).open("w") do |csv_out|
      puts "export csv ..."
      batch = ImportExport::Csv.new(processor, out: csv_out, with_bom: true)
      batch.export
      puts "result: #{batch.result.to_json}"
    end
  end
end
