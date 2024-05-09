class KeaReservation6DelJob < ApplicationJob
  queue_as :default

  def perform(network_id, duid_binary)
    Kea::Host.destroy_by(
      dhcp_identifier: duid_binary,
      host_identifier_type: Kea::HostIdentifierType.duid,
      dhcp6_subnet_id: network_id)
  end
end
