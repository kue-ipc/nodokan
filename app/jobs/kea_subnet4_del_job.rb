class KeaSubnet4DelJob < ApplicationJob
  queue_as :default

  def perform(id)
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit(cascade_transaction: true)
      Kea::Dhcp4Subnet.destroy_by(subnet_id: id)
    end
  end
end
