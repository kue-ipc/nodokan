class KeaReservation4DelJob < ApplicationJob
  queue_as :default

  def perform(mac_address_binary)
    Kea::Host.destroy_by(
      dhcp_identifier: mac_address_binary,
      host_identifier_type: Kea::HostIdentifierType.hw_address)
  end
end
