class KeaReservation6AddJob < ApplicationJob
  queue_as :default

  def perform(network_id, duid, ip)
    duid_binary = [duid.delete("^0-9A-Fa-f")].pack("H*")

    Kea::Host.transaction do
      host = Kea::Host.find_or_create_by!(
        dhcp_identifier: duid_binary,
        host_identifier_type: Kea::HostIdentifierType.duid,
        dhcp6_subnet_id: network_id)

      # view経由のため、reservation_idにnilを入れる必要がある
      reservation = Kea::Ipv6Reservation.find_by(host: host) ||
        Kea::Ipv6Reservation.new(reservation_id: nil, host: host)

      if Kea::Ipv6Reservation.schema_major_version >= 19
        reservation.update!(address: ip.hton)
      else
        reservation.update!(address: ip.to_s)
      end
    end
  end
end
