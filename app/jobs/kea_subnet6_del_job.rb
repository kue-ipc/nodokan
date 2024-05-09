class KeaSubnet6DelJob < ApplicationJob
  queue_as :default

  def perform(id)
    Kea::Dhcp6Subnet.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit
      Kea::Dhcp6Subnet.destroy_by(subnet_id: id)
    end
  end
end
