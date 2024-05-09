class KeaReservation4DelJob < ApplicationJob
  queue_as :default

  def perform(network_id, mac_address_binary)
    Kea::Host.destroy_by(
      dhcp_identifier: mac_address_binary,
      host_identifier_type: Kea::HostIdentifierType.hw_address,
      dhcp4_subnet_id: network_id)
  end
end
