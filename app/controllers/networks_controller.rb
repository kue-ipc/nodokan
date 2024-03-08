class NetworksController < ApplicationController
  include Page
  include Search

  before_action :set_network, only: [:show, :edit, :update, :destroy]
  before_action :authorize_network, only: [:index]

  search_for Network

  # GET /networks
  # GET /networks.json
  # GET /networks.csv
  def index
    set_page
    set_search
    @networks = search_and_sort(policy_scope(Network)).includes(:ipv4_pools, :ipv6_pools)
    respond_to do |format|
      format.html { @networks = paginate(@networks) }
      format.json { @networks = paginate(@networks) }
      format.csv { @networks }
    end
  end

  # GET /networks/1
  # GET /networks/1.json
  def show
  end

  # GET /networks/new
  def new
    @network = Network.new
    authorize @network
  end

  # GET /networks/1/edit
  def edit
  end

  # POST /networks
  # POST /networks.json
  def create
    @network = Network.new(network_params)
    authorize @network

    respond_to do |format|
      if @network.save
        format.turbo_stream { flash.now.notice = t_success(@network, :create) }
        format.html { redirect_to @network, notice: t_success(@network, :create) }
        format.json { render :show, status: :created, location: @network }
      else
        format.html do
          flash.now.alert = t_failure(@network, :create)
          render :new
        end
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /networks/1
  # PATCH/PUT /networks/1.json
  def update
    respond_to do |format|
      if @network.update(network_params)
        format.turbo_stream { flash.now.notice = t_success(@network, :update) }
        format.html { redirect_to @network, notice: t_success(@network, :update) }
        format.json { render :show, status: :ok, location: @network }
      else
        format.html do
          flash.now.alert = t_failure(@network, :update)
          render :edit
        end
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.json
  def destroy
    @network.destroy
    respond_to do |format|
      format.turbo_stream { flash.now.notice = t_success(@network, :delete) }
      format.html { redirect_to networks_url, notice: t_success(@network, :delete) }
      format.json { head :no_content }
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  private def set_network
    @network = policy_scope(Network).find(params[:id])
    authorize @network
  end

  # Only allow a list of trusted parameters through.
  private def network_params
    params.require(:network).permit(
      :name,
      :vlan,
      :auth,
      :dhcp,
      :locked,
      :specific,
      :ipv4_network_address,
      :ipv4_prefix_length,
      :ipv4_gateway_address,
      :ipv6_network_address,
      :ipv6_prefix_length,
      :ipv6_gateway_address,
      :note,
      ipv4_pools_attributes: [
        :id,
        :_destroy,
        :ipv4_config,
        :ipv4_first_address,
        :ipv4_last_address,
      ],
      ipv6_pools_attributes: [
        :id,
        :_destroy,
        :ipv6_config,
        :ipv6_first_address,
        :ipv6_last_address,
      ])
  end

  private def authorize_network
    authorize Network
  end
end
