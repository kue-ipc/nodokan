class KeaReservation6AddJob < ApplicationJob
  queue_as :default

  def perform(network_id, duid_binary, ip)
    Kea::Host.transaction do
      host = Kea::Host.find_or_create_by!(
        dhcp_identifier: duid_binary,
        host_identifier_type: Kea::HostIdentifierType.duid,
        dhcp6_subnet_id: network_id)

      # reservation_idにnilを入れる必要がある
      reservation = Kea::Ipv6Reservation.find_by(host: host)
      if reservation.nil?
        reservaiton = Kea::Ipv6Reservation.new(reservation_id: nil, host: host)
      end
      reservaiton.update!(address: ip.to_s)
    end
  end
end
