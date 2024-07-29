require "json"
require "import_export/network_csv"

namespace :network do
  desc "Export CSV of networks"
  task export: :environment do
    file_out = "networks_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_out).open("w") do |csv_out|
      csv_out << "\u{feff}"
      puts "export csv ..."
      network_csv = ImportExport::NetworkCsv.new(out: csv_out)
      network_csv.export
      puts "result: #{network_csv.result.to_json}"
    end
  end

  desc "Import CSV of networks"
  task import: :environment do
    file_in = "networks.csv"
    file_out = "networks_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"
    (Rails.root / "data" / file_in).open("r:BOM|UTF-8") do |csv_in|
      (Rails.root / "data" / file_out).open("w") do |csv_out|
        csv_out << "\u{feff}"
        puts "import csv ..."
        network_csv = ImportExport::NetworkCsv.new(out: csv_out)
        network_csv.import(csv_in)
        puts "result: #{network_csv.result.to_json}"
      end
    end
  end
end
