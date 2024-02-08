class KeaReservation4AddJob < ApplicationJob
  queue_as :default

  def perform(mac_address_binary, ipv4_u32, network_id)
    Kea::Host.transaction do
      host = Kea::Host.find_or_initialize_by(
        dhcp_identifier: mac_address_binary,
        host_identifier_type: Kea::HostIdentifierType.hw_address)
      return if host.ipv4_address == ipv4_u32 && host.dhcp4_subnet_id == network_id

      host.ipv4_address = ipv4_u32
      host.dhcp4_subnet_id = network_id
      host.save!
    end
  end
end
