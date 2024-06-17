class Ipv4ArpCleanJob < CleanJob
  queue_as :clean

  def perform(now = Time.zone.now)
    clean_records(Ipv4Arp, :ipv4_data, :end_at, now)
  end
end
