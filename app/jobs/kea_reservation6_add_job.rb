class KeaReservation6AddJob < ApplicationJob
  queue_as :default

  def perform(network_id, duid, ip)
    duid_binary = [duid.delete("^0-9A-Fa-f")].pack("H*")

    Kea::Host.transaction do
      host = Kea::Host.find_or_create_by!(
        dhcp_identifier: duid_binary,
        host_identifier_type: Kea::HostIdentifierType.duid,
        dhcp6_subnet_id: network_id)

      host.ipv6_reservation&.update!(ipv6: ip) ||
        host.create_ipv6_reservation(ipv6: ip)
    end
  end
end
