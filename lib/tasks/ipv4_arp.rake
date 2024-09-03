namespace :ipv4_arp do
  desc "Register IPv4 ARP"
  task register: :environment do
    csv_file = Rails.root / "data" / "ipv4_arp_register.csv"
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
        ipv4 = IPAddr.new(row["ip"])
        raise "Not an IPv4 address: #{row['ip']}" unless ipv4.ipv4?
        next if ipv4.loopback?
        next if ipv4.link_local?

        mac_address_data = [row["mac"].delete("-:")].pack("H12")
        next if mac_address_data == null_mac_address_data

        time = Time.zone.at(row["time"].to_i)
        ipv4_arp = Ipv4Arp.where(ipv4_data: ipv4.hton).order(:resolved_at).last
        if ipv4_arp.nil? || ipv4_arp.mac_address_data != mac_address_data
          Ipv4Arp.create!(ipv4_data: ipv4.hton,
            mac_address_data:, resolved_at: time)
          results[:create] += 1
        elsif time > ipv4_arp.resolved_at
          ipv4_arp.update!(resolved_at: time)
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

  desc "Clean IPv4 ARP"
  task clean: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      puts "run job with inline queue adapter"
      Rails.application.config.active_job.queue_adapter = :inline
    end
    puts "add job queue clean ipv4_arp, please see log"
    Ipv4ArpCleanJob.perform_later
  end
end
