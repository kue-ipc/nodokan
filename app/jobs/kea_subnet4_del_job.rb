class KeaSubnet4DelJob < ApplicationJob
  queue_as :default

  def perform(network)
    if network.dhcp && network.ipv4_network
      return
    end

    Kea::Dhcp4Subnet.delete_by(subnet_id: network.id)
  end
end
