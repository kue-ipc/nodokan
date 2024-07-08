class KeaReservation6AddJob < ApplicationJob
  queue_as :default

  def perform(network_id, duid_binary, ip)
    Kea::Host.transaction do
      host = Kea::Host.find_or_create_by!(
        dhcp_identifier: duid_binary,
        host_identifier_type: Kea::HostIdentifierType.duid,
        dhcp6_subnet_id: network_id)

      # view経由のため、reservation_idにnilを入れる必要がある
      reservation = Kea::Ipv6Reservation.find_by(host: host) ||
        Kea::Ipv6Reservation.new(reservation_id: nil, host: host)
      # TODO: スキーマバージョン19未満で分岐
      # reservation.update!(address: ip.to_s)
      # TODO: スキーマバージョン19以降
      reservation.update!(address: ip.hton)
    end
  end
end
