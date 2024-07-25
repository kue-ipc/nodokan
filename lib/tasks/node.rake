require "json"
require "import_export/node_csv"

namespace :node do
  desc "Export CSV of nodes"
  task export: :environment do
    file_out = "nodes_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_out).open("w") do |csv_out|
      csv_out << "\u{feff}"
      puts "export csv ..."
      node_csv = ImportExport::NodeCsv.new(out: csv_out)
      node_csv.export
      puts "result: #{node_csv.result.to_json}"
    end
  end

  desc "Import CSV of nodes"
  task import: :environment do
    file_in = "nodes.csv"
    file_out = "nodes_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_in).open("r:BOM|UTF-8") do |csv_in|
      (Rails.root / "data" / file_out).open("w") do |csv_out|
        csv_out << "\u{feff}"
        puts "export csv ..."
        node_csv = ImportExport::NodeCsv.new(out: csv_out)
        node_csv.import(csv_in)
        puts "result: #{node_csv.result.to_json}"
      end
    end
  end
end
