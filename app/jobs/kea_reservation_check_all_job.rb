require 'set'

class KeaReservationCheckAllJob < ApplicationJob
  queue_as :default

  def perform
    # IPv4
    mac_address_list = Nic.includes(:network)
      .where(network: { dhcp: true })
      .where(ipv4_config: :reserved)
      .where.not(mac_address_data: nil)
      .map(&:mac_address_data)

    Kea::Host
      .where(dhcp_identifier_type: Kea::HostIdentifierType.hw_address.identifier_type)
      .where.not(dhcp_identifier: mac_address_list)
      .destroy_all
  end
end
