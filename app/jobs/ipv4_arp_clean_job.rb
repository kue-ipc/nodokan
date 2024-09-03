class Ipv4ArpCleanJob < CleanJob
  queue_as :clean

  def perform(base: Time.zone.now)
    clean_records(Ipv4Arp, [:ipv4_data, :mac_address_data],
      attr: :end_at, base:)
  end
end
