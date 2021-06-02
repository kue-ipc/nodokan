require 'json'
require 'import_export/network_csv'

namespace :network do
  desc 'Export CSV of networks'
  task export: :environment do
    csv_file = Rails.root / 'data' / 'networks.csv'
    puts 'export csv ...'
    results = ImportExport::NetworkCSV.new(csv_file, logger: Rails.logger).export
    puts results.to_json
  end

  desc 'Import CSV of networks'
  task import: :environment do
    csv_file = Rails.root / 'data' / 'networks.csv'
    puts 'import csv ...'
    results = ImportExport::NetworkCSV.new(csv_file, logger: Rails.logger).import
    puts results.to_json
  end
end
