namespace :ipv6_neighbor do
  desc "Register IPv66 Neighbor"
  task register: :environment do
    PaperTrail.request.disable_model(Ipv6Neighbor)
    csv_file = Rails.root / "data" / "ipv6_neighbor_register.csv"
    puts "register from csv ..."
    results = {
      create: 0,
      update: 0,
      skip: 0,
      error: 0,
    }
    null_mac_address_data = ["00" * 6].pack("H12")

    CSV.open(csv_file, "rb:BOM|UTF-8", headers: :first_row) do |csv|
      csv.each do |row|
        ipv6 = IPAddr.new(row["ip"])
        raise "Not an IPv6 address: #{row['ip']}" unless ipv6.ipv6?
        next if ipv6.loopback?
        next if ipv6.link_local?

        mac_address_data = [row["mac"].delete("-:")].pack("H12")
        next if mac_address_data == null_mac_address_data

        time = Time.zone.at(row["time"].to_i)
        ipv6_neighbor = Ipv6Neighbor.where(ipv6_data: ipv6.hton)
          .order(:discovered_at).last
        if ipv6_neighbor.nil? ||
            ipv6_neighbor.mac_address_data != mac_address_data
          Ipv6Neighbor.create!(ipv6_data: ipv6.hton,
            mac_address_data: mac_address_data, discovered_at: time)
          results[:create] += 1
        elsif time > ipv6_neighbor.discovered_at
          ipv6_neighbor.update!(discovered_at: time)
          results[:update] += 1
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

  desc "Clean IPv6 Neighbor"
  task clean: :environment do
    if Rails.env.production?
      puts "add job queue clean ipv6_neighbor, please see log"
      Ipv6NeighborCleanJob.perform_later
    else
      puts "run job queue clean ipv6_neighbor, please wait..."
      Ipv6NeighborCleanJob.perform_now
    end
  end
end
