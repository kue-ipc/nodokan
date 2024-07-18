class Ipv6NeighborCleanJob < CleanJob
  queue_as :clean

  def perform(date: Time.zone.now)
    clean_records(Ipv6Neighbor, [:ipv6_data, :mac_address_data],
      date_attr: :end_at, date: date)
  end
end
