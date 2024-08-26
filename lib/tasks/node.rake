require "json"

namespace :node do
  desc "Import CSV of nodes"
  task import: :environment do
    name = "nodes"
    processor = ImportExport::Processors::NodesProcessor.new
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

  desc "Export CSV of nodes"
  task export: :environment do
    name = "nodes"
    processor = ImportExport::Processors::NodesProcessor.new
    file_out = "#{name}_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_out).open("w") do |csv_out|
      puts "export csv ..."
      batch = ImportExport::Csv.new(processor, out: csv_out, with_bom: true)
      batch.export
      puts "result: #{batch.result.to_json}"
    end
  end
end
