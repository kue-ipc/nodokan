class KeaReservation4AddJob < ApplicationJob
  queue_as :default

  def perform(network_id, mac_address_binary, ip)
    Kea::Host.transaction do
      host = Kea::Host.find_or_initialize_by(
        dhcp_identifier: mac_address_binary,
        host_identifier_type: Kea::HostIdentifierType.hw_address,
        dhcp4_subnet_id: network_id)
      host.update!(ipv4_address: ip.to_i)
    end
  end
end
