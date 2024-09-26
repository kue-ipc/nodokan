class NicsController < ApplicationController
  before_action :set_nic, only: [:show]

  # GET /nics/1
  # GET /nics/1.json
  def show
    @connections = []
    Ipv4Arp.where(mac_address_data: @nic.mac_address_data)
      .or(Ipv4Arp.where(ipv4_data: @nic.ipv4_data))
      .find_each do |ipv4_arp|
        @connections << [ipv4_arp.resolved_at, ipv4_arp]
      end
    Ipv6Neighbor.where(mac_address_data: @nic.mac_address_data)
      .or(Ipv6Neighbor.where(ipv6_data: @nic.ipv6_data))
      .find_each do |ipv6_neighbor|
        @connections << [ipv6_neighbor.discovered_at, ipv6_neighbor]
      end

    Kea::Lease4.where(hwaddr: @nic.mac_address_data).find_each do |lease4|
      @connections << [lease4.leased_at, lease4]
    end
    Kea::Lease6.where(duid: @nic.node.duid_data).find_each do |lease6|
      @connections << [lease6.leased_at, lease6]
    end

    Radius::Radacct.where(username: @nic.mac_address_raw).find_each do |radacct|
      @connections << [radacct.acctupdatetime, radacct]
    end
    Radius::Radpostauth
      .where(username: @nic.mac_address_raw, reply: "Access-Accept")
      .find_each do |radpostauth|
      @connections << [radpostauth.authdate, radpostauth]
    end

    @connections.sort_by!(&:first)
    @connections.reverse!
  end

  # GET /nics/new
  def new
    new_nic_params = {node: Node.new(user: current_user)}
    if (network = current_user.use_networks.first)
      new_nic_params.merge!({network_id: network.id, auth: network.auth,
      ipv4_config: (Nic.ipv4_configs.keys & network.ipv4_configs).first,
      ipv6_config: (Nic.ipv6_configs.keys & network.ipv6_configs).first,})
    end
    @nic = Nic.new(**new_nic_params)
    authorize @nic
  end

  # Use callbacks to share common setup or constraints between actions.
  private def set_nic
    @nic = policy_scope(Nic)
      .includes(:node, :network)
      .find(params[:id])
    authorize @nic
  end
end
