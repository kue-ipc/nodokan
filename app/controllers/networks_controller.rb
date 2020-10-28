class NetworksController < ApplicationController
  before_action :set_network, only: [:show, :edit, :update, :destroy]
  before_action :authorize_network, only: [:index]

  # GET /networks
  # GET /networks.json
  def index
    permitted_params = params.permit(
      :page,
      :per,
      :format,
      order: [
        :id, :name, :vlan,
      ],
      condition: [:dhcp, :auth, :closed]
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @order = permitted_params[:order]

    @target = permitted_params[:target]&.intern
    @condition = permitted_params[:condition]

    @networks = policy_scope(Network)

    @networks = @networks.where(@condition) if @condition

    @networks = @networks.order(@order.to_h) if @order

    @networks = @networks.page(@page).per(@per)
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
      if params['commit']
        if @network.save
          format.html { redirect_to @network, notice: 'Network was successfully created.' }
          format.json { render :show, status: :created, location: @network }
        else
          format.html { render :new }
          format.json { render json: @network.errors, status: :unprocessable_entity }
        end
      elsif params['add_ip_pool'] && @network.ip_network
        ip_next = @network.ip_next
        @network.ip_pools << IpPool.new(
          ip_config: :static,
          first_address: ip_next,
          last_address: ip_next
        )
        format.html { render :new }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      elsif params['add_ip6_pool'] && @network.ip6_network
        ip6_next = @network.ip6_next
        @network.ip6_pools << Ip6Pool.new(
          ip6_config: :static,
          first6_address: ip6_next,
          last6_address: ip6_next
        )
        format.html { render :new }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      else
        format.html { render :new }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /networks/1
  # PATCH/PUT /networks/1.json
  def update
    respond_to do |format|
      if params['commit']
        if @network.update(network_params)
          format.html { redirect_to @network, notice: 'Network was successfully updated.' }
          format.json { render :show, status: :ok, location: @network }
        else
          format.html { render :edit }
          format.json { render json: @network.errors, status: :unprocessable_entity }
        end
      elsif params['add_ip_pool']
        @network.assign_attributes(network_params)
        ip_next = @network.ip_next
        @network.ip_pools << IpPool.new(
          ip_config: :static,
          first_address: ip_next,
          last_address: ip_next
        )
        format.html { render :edit }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      elsif params['add_ip6_pool'] && @network.ip6_network
        @network.assign_attributes(network_params)
        ip6_next = @network.ip6_next
        @network.ip6_pools << Ip6Pool.new(
          ip6_config: :static,
          first6_address: ip6_next,
          last6_address: ip6_next
        )
        format.html { render :edit }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      else
        @network.assign_attributes(network_params)
        format.html { render :edit }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /networks/1
  # DELETE /networks/1.json
  def destroy
    @network.destroy
    respond_to do |format|
      format.html { redirect_to networks_url, notice: 'Network was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_network
      @network = policy_scope(Network).find(params[:id])
      authorize @network
    end

    # Only allow a list of trusted parameters through.
    def network_params
      params.require(:network).permit(
        :name,
        :vlan,
        :dhcp,
        :auth,
        :closed,
        :ip_address,
        :ip_mask,
        :ip_gateway,
        :ip6_address,
        :ip6_prefix,
        :ip6_gateway,
        ip_pools_attributes: [
          :id,
          :_destroy,
          :ip_config,
          :first_address,
          :last_address,
        ],
        ip6_pools_attributes: [
          :id,
          :_destroy,
          :ip6_config,
          :first6_address,
          :last6_address,
        ]
      )
    end

    def authorize_network
      authorize Network
    end
end
