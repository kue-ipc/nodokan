class Ipv6NeighborCleanJob < CleanJob
  queue_as :clean

  def perform(base: Time.zone.now)
    clean_records(Ipv6Neighbor, [:ipv6_data, :mac_address_data],
      attr: :end_at, base: base)
  end
end
