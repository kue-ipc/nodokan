class Ipv6NeighborCleanJob < CleanJob
  queue_as :clean

  def perform(now = Time.zone.now)
    clean_records(Ipv6Neighbor, :ipv6_data, :end_at, now)
  end
end
