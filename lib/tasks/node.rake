require "json"
require "import_export/node_csv"

namespace :node do
  desc "Export CSV of nodes"
  task export: :environment do
    (Rails.root / "data" / "nodes.csv").open("w") do |csv_file|
      csv_file << "\u{feff}"
      puts "export csv ..."
      node_csv = ImportExport::NodeCsv.new(out: csv_file)
      node_csv.export
      puts "result: #{node_csv.result.to_json}"
    end
  end

  desc "Import CSV of nodes"
  task import: :environment do
    csv_file = Rails.root / "data" / "nodes.csv"
    puts "import csv ..."
    results = ImportExport::NodeCsv.new(csv_file, logger: Rails.logger).import
    puts results.to_json
  end
end
