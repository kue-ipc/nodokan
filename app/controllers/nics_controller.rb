class NicsController < ApplicationController
  before_action :set_nic, only: [:show]

  # GET /nics/1
  # GET /nics/1.json
  def show
    if @nic.ipv4_data
      @ipv4_arp = Ipv4Arp.where(ipv4_data: @nic.ipv4_data)
        .order(:resolved_at).last
    end
    if @nic.ipv6_data
      @ipv6_neighbor = Ipv6Neighbor.where(ipv6_data: @nic.ipv6_data)
        .order(:discovered_at).last
    end
    if @nic.mac_address_data
      @lease4 = Kea::Lease4.where(hwaddr: @nic.mac_address_data)
        .order(:expire).last
      @lease6 = Kea::Lease6.where(hwaddr: @nic.mac_address_data)
        .order(:expire).last
      @radpostauth = Radius::Radpostauth.where(username: @nic.mac_address_raw)
        .order(:authdate).last
    end
  end

  # GET /nics/new
  def new
    @nic = Nic.new
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
