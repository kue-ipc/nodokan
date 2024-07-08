class KeaReservation6DelJob < ApplicationJob
  queue_as :default

  def perform(network_id, duid)
    duid_binary = [duid.delete("^0-9A-Fa-f")].pack("H*")

    Kea::Host.destroy_by(
      dhcp_identifier: duid_binary,
      host_identifier_type: Kea::HostIdentifierType.duid,
      dhcp6_subnet_id: network_id)
  end
end
