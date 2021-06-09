class KeaSubnet4DelJob < ApplicationJob
  queue_as :default

  def perform(network)
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit
      Kea::Dhcp4Subnet.destroy_by(subnet_id: network.id)
    end
  end
end
