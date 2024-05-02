class KeaReservation6AddJob < ApplicationJob
  queue_as :default

  def perform(duid_binary, ipv6_address, network_id)
    Kea::Host.transaction do
      host = Kea::Host.find_or_initialize_by(
        dhcp_identifier: duid_binary,
        host_identifier_type: Kea::HostIdentifierType.duid)
      unless host.dhcp6_subnet_id == network_id
        host.dhcp6_subnet_id = network_id
        host.save!
      end

      reservation = Kea::Ipv6Reservation.find_by(host: host)
      if reservation.nil?
        Kea::Ipv6Reservation.create(
          reservation_id: nil,
          address: ipv6_address)
      elsif reservaiton.address != ipv6_address
        reservaiton.update!(address: ipv6_address)
      end
    end
  end
end
