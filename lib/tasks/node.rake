require "json"

namespace :node do
  desc "Export CSV of nodes"
  task export: :environment do
    file_out = "nodes_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_out).open("w") do |csv_out|
      puts "export csv ..."
      node_csv = ImportExport::NodeCsv.new(out: csv_out, with_bom: true)
      node_csv.export
      puts "result: #{node_csv.result.to_json}"
    end
  end

  desc "Import CSV of nodes"
  task import: :environment do
    file_in = "nodes.csv"
    file_out = "nodes_#{Time.current.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_in).open("r:BOM|UTF-8") do |csv_in|
      (Rails.root / "data" / file_out).open("w") do |csv_out|
        puts "import csv ..."
        node_csv = ImportExport::NodeCsv.new(out: csv_out, with_bom: true)
        node_csv.import(csv_in)
        puts "result: #{node_csv.result.to_json}"
      end
    end
  end
end
