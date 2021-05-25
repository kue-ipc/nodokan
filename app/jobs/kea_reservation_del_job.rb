class KeaReservationDelJob < ApplicationJob
  queue_as :default

  def perform(nic)
    if nic.mac_address_data.present?
      # hw-address: 0
      Kea::Host.destroy_by(
        dhcp_identifier: nic.mac_address_data,
        dhcp_identifier_type: 0
      )
    end
  end
end
