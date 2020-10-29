class NodesController < ApplicationController
  before_action :set_node, only: [:show, :edit, :update, :destroy]
  before_action :authorize_node, only: [:index]

  # GET /nodes
  # GET /nodes.json
  def index
    permitted_params = params.permit(
      :page,
      :per,
      :format,
      :query,
      :search,
      order: [
        :id, :name, :hostname, :domain, :place_id, :hardware_id, :operating_system_id, :confirmed_at,
      ],
      condition: [
        :name, :hostname, :domain, :place_id, :hardware_id,
        :operating_system_id, :confirmed_at,
      ]
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]

    if ['csv', 'json'].include?(permitted_params[:format])
      @per = 10000
    end

    @order = permitted_params[:order]

    @query = permitted_params[:query]

    @condition = permitted_params[:condition]

    @nodes = policy_scope(Node)
      .includes(:user, :place, :hardware, :operating_system, nics: :network)

    if @query.present?
      query_places = Place.where(
        'area LIKE :query OR ' \
        'building LIKE :query OR ' \
        'room LIKE :query',
        {query: "%#{@query}%"}
      )

      query_hardwares = Hardware.where(
        'maker LIKE :query OR ' \
        'product_name LIKE :query OR ' \
        'model_number LIKE :query',
        {query: "%#{@query}%"}
      )

      query_nics = Nic.where(
        'name LIKE :query OR ' \
        'ip_address LIKE :query OR ' \
        'ip6_address LIKE :query',
        {query: "%#{@query}%"}
      )

      @nodes = @nodes
        .where(
          'name LiKE :query OR ' \
          'hostname LIKE :query OR ' \
          'domain LIKE :query',
          {query: "%#{@query}%"}
        )
        .or(@nodes.where(place_id: query_places.map(&:id)))
        .or(@nodes.where(hardware_id: query_hardwares.map(&:id)))
        .or(@nodes.where(nics: query_nics.map(&:id)))
    end

    @nodes = @nodes.where(@condition) if @condition

    @nodes = @nodes.order(@order.to_h) if @order

    @nodes = @nodes.page(@page).per(@per)


    # SELECT `nodes`.* FROM `nodes` WHERE (NOT (`nodes`.`confirmed_at` >= '2019-10-28 06:54:41') OR `nodes`.`confirmed_at` IS NULL)


    # where('NOT (`nodes`.`confirmed_at` >= :time) OR `nodes`.`confirmed_at` IS NULL', time: Time.current.ago(1.year)...)
    #       .or

    # @q = params[:q].presence
    # @uc = params[:uc].presence&.to_i&.positive? || false

    # @nodes =
    #   if @uc
    #     policy_scope(Node).where.not(confirmed_at: Time.current.ago(1.year)..)
    #       .or(policy_scope(Node).where(confirmed_at: nil))
    #   else
    #     policy_scope(Node)
    #   end

    # if @q
    #   @nodes = @nodes.where(
    #     'name LiKE :q OR ' \
    #     'hostname LIKE :q',
    #     {q: "%#{@q}%"}
    #   )
    # end

    # @nodes = @nodes
    #   .includes(:user, :place, :hardware, :operating_system, nics: :network)
    #   .page(params[:page])
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
  end

  # GET /nodes/new
  def new
    @node = Node.new(
      place: Place.new,
      hardware: Hardware.new,
      operating_system: OperatingSystem.new,
      nics: [Nic.new],
      user: current_user
    )
    authorize @node
  end

  # GET /nodes/1/edit
  def edit
  end

  # POST /nodes
  # POST /nodes.json
  def create
    @node = Node.new(node_params)
    authorize @node

    respond_to do |format|
      if params['commit']
        if @node.save
          format.html { redirect_to @node, notice: 'Node was successfully created.' }
          format.json { render :show, status: :created, location: @node }
        else
          format.html { render :new }
          format.json { render json: @node.errors, status: :unprocessable_entity }
        end
      elsif params['add_nic']
        @node.nics << Nic.new
        format.html { render :new }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nodes/1
  # PATCH/PUT /nodes/1.json
  def update
    respond_to do |format|
      if params['commit']
        if @node.update(node_params)
          format.html { redirect_to @node, notice: 'Node was successfully updated.' }
          format.json { render :show, status: :ok, location: @node }
        else
          format.html { render :edit }
          format.json { render json: @node.errors, status: :unprocessable_entity }
        end
      elsif params['add_nic']
        @node.nics << Nic.new
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

  # GET /nodes/1/copy
  def copy
    @original_node = Node.find(params[:id])
    authorize @original_node
    @node = Node.new(
      domain: @original_node.domain,
      place: @original_node.place,
      hardware: @original_node.hardware,
      operating_system: @original_node.operating_system,
      nics: @original_node.nics.map do |nic|
        Nic.new(
          name: nic.name,
          interface_type: nic.interface_type,
          network: nic.network,
          ip_config: nic.ip_config,
          ip6_config: nic.ip6_config,
        )
      end
    )
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_node
      @node = policy_scope(Node)
        .includes(:user, :place, :hardware, :operating_system, nics: :network)
        .find(params[:id])
      authorize @node
    end

    # Only allow a list of trusted parameters through.
    def node_params
      permitted_params = params.require(:node).permit(
        :name,
        :hostname,
        :domain,
        :note,
        user: [
          :username,
        ],
        place: [
          :area,
          :building,
          :floor,
          :room,
        ],
        hardware: [
          :device_type,
          :maker,
          :product_name,
          :model_number,
        ],
        operating_system: [
          :os_category,
          :name,
        ],
        nics_attributes: [
          :id,
          :_destroy,
          :name,
          :interface_type,
          :mac_address,
          :duid,
          :network_id,
          :ip_config,
          :ip_address,
          :ip6_config,
          :ip6_address,
        ]
      )

      user = User.find_by(permitted_params[:user])

      place = Place.find_or_initialize_by(permitted_params[:place])

      hardware =
        if permitted_params[:hardware][:device_type].present?
          Hardware.find_or_initialize_by(permitted_params[:hardware])
        end

      operating_system =
        if permitted_params[:operating_system][:os_category].present?
          OperatingSystem.find_or_initialize_by(permitted_params[:operating_system])
        end

      permitted_params.except(:place, :hardware, :operating_system).merge(
        {
          user: user,
          place: place,
          hardware: hardware,
          operating_system: operating_system,
          user_id: current_user.id,
        }
      )
    end

    def authorize_node
      authorize Node
    end
end
