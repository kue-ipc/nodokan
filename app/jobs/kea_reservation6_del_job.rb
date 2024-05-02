class KeaReservation6DelJob < ApplicationJob
  queue_as :default

  def perform(duid_binary)
    Kea::Host.destroy_by(
      dhcp_identifier: duid_binary,
      host_identifier_type: Kea::HostIdentifierType.duid)
  end
end
