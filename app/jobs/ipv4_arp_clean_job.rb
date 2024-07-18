class Ipv4ArpCleanJob < CleanJob
  queue_as :clean

  def perform(date: Time.zone.now)
    clean_records(Ipv4Arp, [:ipv4_data, :mac_address_data], date_attr: :end_at,
      date: date)
  end
end
