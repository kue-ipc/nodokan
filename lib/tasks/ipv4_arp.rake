require 'csv'

namespace :ipv4_arp do
  desc "register ipv4 arp"
  task register: :environment do
    csv_file = Rails.root / 'data' / 'ipv4_register.csv'
    puts 'register from csv ...'
    CSV.open(csv_file, 'rb:BOM|UTF-8', headers: :first_row) do |csv|
      pp csv.headres
      csv.each do |row|
        ipv4_data = IPAddress::IPv4.parse(row['ip']).data
        mac_address_data = [row['mac'].delete('-:')].pack('H12')
        time = Time.at(row['time'].to_i)
        ipv4_arp = Ipv4Arp.find_or_initialize_by(ipv4_data: ipv4_data, mac_address_data: mac_address_data)
        if ipv4_arp.resolved_at.nil? || time > ipv4_arp.resolved_at
          ipv4_arp.resolved_at = time
          ipv4_arp.save
        end
      end
    end
  end
end
