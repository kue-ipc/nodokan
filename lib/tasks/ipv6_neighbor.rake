namespace :ipv6_neighbor do
  desc "register ipv6 neighbor"
  task register: :environment do
    PaperTrail.request.disable_model(Ipv6Neighbor)
    csv_file = Rails.root / "data" / "ipv6_neighbor_register.csv"
    puts "register from csv ..."
    results = {
      success: 0,
      skip: 0,
      failure: 0,
      error: 0,
    }
    CSV.open(csv_file, "rb:BOM|UTF-8", headers: :first_row) do |csv|
      csv.each do |row|
        ipv6 = IPAddr.new(row["ip"])
        raise "Not an IPv6 address: #{row['ip']}" unless ipv6.ipv6?
        next if ipv6.loopback?
        next if ipv6.link_local?

        mac_address_data = [row["mac"].delete("-:")].pack("H12")
        time = Time.zone.at(row["time"].to_i)
        ipv6_neighbor = Ipv6Neighbor.find_or_initialize_by(
          ipv6_data: ipv6.hton, mac_address_data: mac_address_data)
        if ipv6_neighbor.discovered_at.nil? ||
            time > ipv6_neighbor.discovered_at
          ipv6_neighbor.discovered_at = time
          if ipv6_neighbor.save
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
