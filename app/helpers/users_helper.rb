module UsersHelper
  def vlan_or_id(network)
    return nil unless network

    if network.vlan
      'v' + network.vlan.to_s
    else
      '#' + network.id.to_s
    end
  end
end
