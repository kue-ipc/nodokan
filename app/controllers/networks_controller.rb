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
      :query,
      order: [
        :id, :name, :vlan, :ipv4_network, :ipv6_network,
        :nics_count, :assignments_count,
      ],
      condition: [:auth, :nics_count, :assignments_count]
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @query = permitted_params[:query]
    @order = permitted_params[:order]
    @condition = permitted_params[:condition]

    @networks = policy_scope(Network).includes(:ipv4_pools, :ipv6_pools)

    if @query.present?
      @networks = @networks.where('name LIKE :query', {query: "%#{@query}%"})
    end

    @networks = @networks.where(@condition) if @condition

    if @order
      order_hash = @order.to_h.transform_keys do |key|
        if ['ipv4_network', 'ipv6_network'].include?(key)
          key + '_data'
        else
          key
        end
      end
      @networks = @networks.order(order_hash)
    end

    unless permitted_params[:format] == 'csv'
      @networks = @networks.page(@page).per(@per)
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
      if params['commit']
        if @network.save
          format.html { redirect_to @network, notice: 'Network was successfully created.' }
          format.json { render :show, status: :created, location: @network }
        else
          format.html { render :new }
          format.json { render json: @network.errors, status: :unprocessable_entity }
        end
      elsif params['add_ip_pool'] && @network.ipv4_network
        next_ipv4 = @network.next_ipv4_pool
        @network.ipv4_pools << Ipv4Pool.new(
          ipv4_config: :static,
          ipv4_first_address: next_ipv4&.address,
          ipv4_last_address: next_ipv4&.address
        )
        format.html { render :new }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      elsif params['add_ipv6_pool'] && @network.ipv6_network
        next_ipv6 = @network.next_ipv6_pool
        @network.ipv6_pools << Ipv6Pool.new(
          ipv6_config: :static,
          ipv6_first_address: next_ipv6&.address,
          ipv6_last_address: next_ipv6&.address
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
        next_ipv4 = @network.next_ipv4_pool
        @network.ipv4_pools << Ipv4Pool.new(
          ipv4_config: :static,
          ipv4_first_address: next_ipv4&.address,
          ipv4_last_address: next_ipv4&.address
        )
        format.html { render :edit }
        format.json { render json: @network.errors, status: :unprocessable_entity }
      elsif params['add_ipv6_pool'] && @network.ipv6_network
        @network.assign_attributes(network_params)
        next_ipv6 = @network.next_ipv6_pool
        @network.ipv6_pools << Ipv6Pool.new(
          ipv6_config: :static,
          ipv6_first_address: next_ipv6&.address,
          ipv6_last_address: next_ipv6&.address
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
        :auth,
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
        ]
      )
    end

    def authorize_network
      authorize Network
    end
end
