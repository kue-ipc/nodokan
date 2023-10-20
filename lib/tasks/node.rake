require "json"
require "import_export/node_csv"

namespace :node do
  desc "Export CSV of nodes"
  task export: :environment do
    csv_file = Rails.root / "data" / "nodes.csv"
    puts "export csv ..."
    results = ImportExport::NodeCSV.new(csv_file, logger: Rails.logger).export
    puts results.to_json
  end

  desc "Import CSV of nodes"
  task import: :environment do
    csv_file = Rails.root / "data" / "nodes.csv"
    puts "import csv ..."
    results = ImportExport::NodeCSV.new(csv_file, logger: Rails.logger).import
    puts results.to_json
  end
end
