class NodesController < ApplicationController
  before_action :set_node, only: [:show, :edit, :update, :destroy]

  # GET /nodes
  # GET /nodes.json
  def index
    @nodes = Node.all
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
  end

  # GET /nodes/new
  def new
    @node = Node.new(
      location: Place.new,
      hardware: Hardware.new,
      operating_system: OperatingSystem.new,
      network_interfaces: [
        NetworkInterface.new(
          network_connections: [
            NetworkConnection.new(
              ip_addresses: [
                IpAddress.new(ip_version: 4)
              ]
            )
          ]
        )
      ]
    )
  end

  # GET /nodes/1/edit
  def edit
  end

  # POST /nodes
  # POST /nodes.json
  def create
    @node = Node.new(node_params)

    respond_to do |format|
      if @node.save
        format.html { redirect_to @node, notice: 'Node was successfully created.' }
        format.json { render :show, status: :created, location: @node }
      else
        format.html { render :new }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nodes/1
  # PATCH/PUT /nodes/1.json
  def update
    respond_to do |format|
      if @node.update(node_params)
        format.html { redirect_to @node, notice: 'Node was successfully updated.' }
        format.json { render :show, status: :ok, location: @node }
      else
        format.html { render :edit }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.json
  def destroy
    @node.destroy
    respond_to do |format|
      format.html { redirect_to nodes_url, notice: 'Node was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_node
      @node = Node.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def node_params
      permitted_params = params.require(:node).permit(
        :name,
        :hostname,
        :domain,
        :note,
        :security_software_id,
        place: [
          :area,
          :building,
          :floor,
          :room
        ],
        hardware: [
          :category,
          :maker,
          :product_name,
          :model_number
        ],
        operating_system: [
          :category,
          :name
        ],
        network_interfaces_attributes: [
          :name,
          :interface_type,
          :mac_address,
          {
            network_connections_attributes: [
              :subnetwork_id,
              {
                ip_addresses_attributes: [
                  :config,
                  :ip_version,
                  :address
                ],
              }
            ]
          }
        ]
      )

      place = Place.find_or_create_by(permitted_params[:place])
      hardware = if permitted_params[:hardware][:category].present?
        Hardware.find_or_create_by(permitted_params[:hardware])
      end
      operating_system = if permitted_params[:operating_system][:category].present?
        OperatingSystem.find_or_create_by(permitted_params[:operating_system])
      end

      permitted_params.except(:place, :hardware, :operating_system).merge(
        {
          location: place,
          hardware: hardware,
          operating_system: operating_system,
          user_id: current_user.id
        })
    end
end
