class KeaReservationAddJob < ApplicationJob
  queue_as :default

  def perform(nic)
    if nic.ipv4_reserved? &&
       nic.mac_address_data.present? &&
       nic.ipv4_data.present? &&
       nic.network&.dhcp
      # hw-address: 0
      host = Kea::Host.find_or_initialize_by(
        dhcp_identifier: nic.mac_address_data,
        dhcp_identifier_type: 0
      )
      host.dhcp4_subnet_id = nic.network_id
      host.ipv4_address = nic.ipv4.to_i
      host.save
    end

    # TODO: IPv6
  end
end
