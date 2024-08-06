require "stringio"

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
    @networks = search_and_sort(policy_scope(Network))
      .includes(:ipv4_pools, :ipv6_pools)
    respond_to do |format|
      format.html do
        @networks = paginate(@networks)
      end
      format.json do
        @networks = paginate(@networks)
      end
      format.csv do
        io = StringIO.new
        io << "\u{feff}"
        network_csv = ImportExport::NetworkCsv.new(current_user, out: io)
        network_csv.export(@networks)
        send_data io.string
      end
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
        format.turbo_stream do
          flash.now.notice = t_success(@network, :create)
        end
        format.html do
          redirect_to @network, notice: t_success(@network, :create)
        end
        format.json do
          render :show, status: :created, location: @network
        end
      else
        format.html do
          flash.now.alert = t_failure(@network, :create)
          render :new
        end
        format.json do
          render json: @network.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /networks/1
  # PATCH/PUT /networks/1.json
  def update
    respond_to do |format|
      if @network.update(network_params)
        format.turbo_stream do
          flash.now.notice = t_success(@network, :update)
        end
        format.html do
          redirect_to @network, notice: t_success(@network, :update)
        end
        format.json { render :show, status: :ok, location: @network }
      else
        format.html do
          flash.now.alert = t_failure(@network, :update)
          render :edit
        end
        format.json do
          render json: @network.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.json
  def destroy
    @network.destroy
    respond_to do |format|
      format.turbo_stream do
        flash.now.notice = t_success(@network, :delete)
      end
      format.html do
        redirect_to networks_url, notice: t_success(@network, :delete)
      end
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
      :locked,
      :specific,
      :dhcp,
      :ra,
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
