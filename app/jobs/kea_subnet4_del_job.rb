class KeaSubnet4DelJob < ApplicationJob
  queue_as :default

  def perform(id)
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit(cascade_transaction: true)
      Kea::Dhcp4Subnet.destroy_by(subnet_id: id)
    end
    # destroy hosts without subnet_id
    Kea::Host.where(dhcp4_subnet_id: nil, dhcp6_subnet_id: nil).destroy_all
  end
end
