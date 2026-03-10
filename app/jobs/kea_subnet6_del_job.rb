class KeaSubnet6DelJob < ApplicationJob
  queue_as :default

  def perform(id)
    Kea::Dhcp6Subnet.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit(cascade_transaction: true)
      Kea::Dhcp6Subnet.destroy_by(subnet_id: id)
    end
    # destroy hosts without subnet_id
    Kea::Host.where(dhcp4_subnet_id: nil, dhcp6_subnet_id: nil).destroy_all
  end
end
