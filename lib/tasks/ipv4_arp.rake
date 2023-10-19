require 'csv'

namespace :ipv4_arp do
  desc 'register ipv4 arp'
  task register: :environment do
    PaperTrail.request.disable_model(Ipv4Arp)
    csv_file = Rails.root / 'data' / 'ipv4_arp_register.csv'
    puts 'register from csv ...'
    results = {
      success: 0,
      skip: 0,
      failure: 0,
      error: 0,
    }
    CSV.open(csv_file, 'rb:BOM|UTF-8', headers: :first_row) do |csv|
      csv.each do |row|
        ipv4_data = IPAddress::IPv4.new(row['ip']).data
        mac_address_data = [row['mac'].delete('-:')].pack('H12')
        time = Time.at(row['time'].to_i)
        ipv4_arp = Ipv4Arp.find_or_initialize_by(ipv4_data: ipv4_data, mac_address_data: mac_address_data)
        if ipv4_arp.resolved_at.nil? || time > ipv4_arp.resolved_at
          ipv4_arp.resolved_at = time
          if ipv4_arp.save
            results[:success] += 1
          else
            results[:failure] += 1
          end
        else
          results[:skip] += 1
        end
      rescue StandardError => e
        Rails.logger.error(e.full_message)
        results[:error] += 1
      end
    end
    puts results.to_json
  end
end
