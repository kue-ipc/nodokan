class NodesController < ApplicationController
  before_action :set_node, only: [:show, :edit, :update, :destroy, :transfer, :apply_specific]
  before_action :authorize_node, only: [:index]

  # GET /nodes
  # GET /nodes.json
  def index
    permitted_params = params.permit(
      :page, :per, :format,
      :query,
      :search,
      order: [:user, :name, :hostname, :domain, :place, :hardware, :operating_system,
              :ipv4_address, :ipv6_address, :mac_address],
      condition: [:user, :name, :hostname, :domain, :place_id, :hardware_id, :operating_system_id],
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]

    @order = permitted_params[:order]

    @query = permitted_params[:query]

    @condition = permitted_params[:condition]

    @nodes = policy_scope(Node).includes(:user, :place, :hardware, :operating_system, :confirmation, nics: :network)

    if @query.present?
      query_places = Place.where(
        'area LIKE :query OR ' \
        'building LIKE :query OR ' \
        'room LIKE :query',
        { query: "%#{@query}%" },
      )

      query_hardwares = Hardware.where(
        'maker LIKE :query OR ' \
        'product_name LIKE :query OR ' \
        'model_number LIKE :query',
        { query: "%#{@query}%" },
      )

      query_nics = nil
      begin
        query_ip = IPAddress.parse(@query)
        if query_ip.ipv4?
          query_nics = Nic.where(ipv4_data: query_ip.data)
        elsif query_ip.ipv6?
          query_nics = Nic.where(ipv6_data: query_ip.data)
        end
      rescue ArgumentError
        if @query =~ /\A\h{2}(?:[-:.]?\h{2}){5}\z/
          query_mac = [@query.delete('-:')].pack('H12')
          query_nics = Nic.where(mac_address_data: query_mac)
        end
      end

      if query_nics
        @nodes = @nodes
          .where(
            'name LIKE :query OR ' \
            'hostname LIKE :query OR ' \
            'domain LIKE :query',
            { query: "%#{@query}%" },
          )
          .or(@nodes.where(place_id: query_places.map(&:id)))
          .or(@nodes.where(hardware_id: query_hardwares.map(&:id)))
          .or(@nodes.where(nics: query_nics))
      else
        @nodes = @nodes
          .where(
            'name LIKE :query OR ' \
            'hostname LIKE :query OR ' \
            'domain LIKE :query',
            { query: "%#{@query}%" },
          )
          .or(@nodes.where(place_id: query_places.map(&:id)))
          .or(@nodes.where(hardware_id: query_hardwares.map(&:id)))
      end
    end

    @nodes = @nodes.where(@condition) if @condition

    @order&.each do |key, value|
      value = if value.to_s.downcase == 'desc'
                'desc'
              else
                'asc'
              end

      case key
      when 'user'
        @nodes = @nodes.order("users.username #{value}")
      when 'name', 'hostname', 'domain'
        @nodes = @nodes.order({ key => value })
      when 'place'
        @nodes = @nodes.order("places.room #{value}")
      when 'hardware'
        @nodes = @nodes.order("hardwares.product_name #{value}")
      when 'operating_system'
        @nodes = @nodes.order("operating_systems.name #{value}")
      when 'ipv4_address'
        @nodes = @nodes.order("nics.ipv4_data #{value}")
      when 'ipv6_address'
        @nodes = @nodes.order("nics.ipv6_data #{value}")
      when 'mac_address'
        @nodes = @nodes.order("nics.mac_address_data #{value}")
      end
    end

    @nodes = @nodes.page(@page).per(@per) unless permitted_params[:format] == 'csv'
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
    @confirmation = @node.confirmation || @node.build_confirmation

    # check os
    if @node.operating_system
      @installation_methods = policy_scope(SecuritySoftware)
        .where(os_category: @node.operating_system.os_category)
        .select(:installation_method)
        .distinct
        .map(&:installation_method)

      if @confirmation.security_software&.os_category != @node.operating_system.os_category
        @confirmation.security_software = SecuritySoftware.new(
          os_category: @node.operating_system.os_category,
        )
        @confirmation.security_update = nil
        @confirmation.security_scan = nil
      end
    else
      @installtaion_methods = []
      @confirmation.security_software = nil
      @confirmation.security_update = nil
      @confirmation.security_scan = nil
    end

    # unknown -> nil
    @confirmation.content = nil if @confirmation.content_unknown?
    @confirmation.os_update = nil if @confirmation.os_update_unknown?
    @confirmation.app_update = nil if @confirmation.app_update_unknown?
    @confirmation.security_update = nil if @confirmation.security_update_unknown?
    @confirmation.security_scan = nil if @confirmation.security_scan_unknown?
  end

  # GET /nodes/new
  def new
    @node = Node.new(
      place: Place.new,
      hardware: Hardware.new,
      operating_system: OperatingSystem.new,
      nics: [Nic.new],
      user: current_user,
    )
    authorize @node

    if current_user.usable_networks.count.zero?
      redirect_to root_path, alert: 'あなたのアカウントには選択可能なネットワークがないため、端末の新規登録はできません。'
    end
  end

  # GET /nodes/1/edit
  def edit
  end

  # POST /nodes
  # POST /nodes.json
  def create
    @node = Node.new(node_params)
    @node.user = current_user unless current_user.admin?
    authorize @node

    if params['add_nic']
      @node.nics << Nic.new
      render :new
      return
    end

    number_count = 1
    @node.nics.each do |nic|
      unless current_user.admin?
        nic.errors[:ipv4_config] << '管理者以外は手動に設定できません。' if nic.ipv4_config == 'manual'
        nic.errors[:ipv4_config] << '管理者以外は手動に設定できません。' if nic.ipv6_config == 'manual'
      end

      nic.number = number_count
      nic.set_ipv4!
      nic.set_ipv6!

      number_count += 1
    end

    success = false

    Node.transaction do
      if !@node.save ||
         @node.errors.present? ||
         @node.place&.errors&.present? ||
         @node.hardware&.errors&.present? ||
         @node.operating_system&.errors&.present? ||
         @node.nics.any? { |nic| nic.errors.present? }
        raise ActiveRecord::Rollback
      end

      success = true
    end

    respond_to do |format|
      if success
        format.html { redirect_to @node, notice: '端末を登録しました。' }
        format.json { render :show, status: :created, location: @node }
      else
        format.html do
          flash.now[:alert] = '端末登録に失敗しました。'
          render :new
        end
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nodes/1
  # PATCH/PUT /nodes/1.json
  def update
    @node.assign_attributes(node_params)
    @node.user = current_user unless current_user.admin?

    if params['add_nic']
      @node.nics << Nic.new
      render :edit
      return
    end

    number_count = 1
    @node.nics.each do |nic|
      unless current_user.admin?
        if nic.ipv4_config == 'manual' &&
           !same_old_nic?(:network_id, :ipv4_config)
          nic.errors[:ipv4_config] << '管理者以外は手動に設定できません。'
        end
        if nic.ipv6_config == 'manual' &&
           !same_old_nic?(:network_id, :ipv6_config)
          nic.errors[:ipv4_config] << '管理者以外は手動に設定できません。'
        end
      end

      nic.number = number_count
      nic.set_ipv4!
      nic.set_ipv6!

      number_count += 1
    end

    success = false

    Node.transaction do
      if !@node.save ||
         @node.errors.present? ||
         @node.place&.errors&.present? ||
         @node.hardware&.errors&.present? ||
         @node.operating_system&.errors&.present? ||
         @node.nics.any? { |nic| nic.errors.present? }
        raise ActiveRecord::Rollback
      end

      success = true
    end

    respond_to do |format|
      if success
        format.html { redirect_to @node, notice: '端末を更新しました。' }
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
    respond_to do |format|
      if @node.specific
        format.html { redirect_to @node, alert: '特定端末は削除できません。特定端末の解除を申請してください。' }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      elsif @node.destroy
        format.html { redirect_to nodes_url, notice: '端末を削除しました。' }
        format.json { head :no_content }
      else
        format.html { redirect_to @node, alert: '端末の削除に失敗しました。' }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
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
          ipv4_config: nic.ipv4_config,
          ipv6_config: nic.ipv6_config,
        )
      end,
    )
  end

  # POST /nodes/1/tranfer
  def transfer
    user = User.find_by(username: params[:username])
    if user
      @node.user = user
      @node.confirmation = nil
      respond_to do |format|
        if @node.save
          format.html { redirect_to nodes_path, notice: '端末を譲渡しました。' }
          format.json { render :show, status: :ok, location: @node }
        else
          format.html { redirect_to @node, alert: '移譲に失敗しました。' }
          format.json { render json: @node.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @node, alert: '該当するユーザーがいません。' }
        format.json { render json: { username: '該当のユーザーがいません。' }, status: :unprocessable_entity }
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  private def set_node
    @node = policy_scope(Node)
      .includes(:user, :place, :hardware, :operating_system, nics: :network)
      .find(params[:id])
    authorize @node
  end

  # Only allow a list of trusted parameters through.
  private def node_params
    permitted_params = params.require(:node).permit(
      :name,
      :hostname,
      :domain,
      :specific,
      :note,
      :user_id,
      place: [:area, :building, :floor, :room],
      hardware: [:device_type_id, :maker, :product_name, :model_number],
      operating_system: [:os_category_id, :name],
      nics_attributes: [
        :id,
        :_destroy,
        :name,
        :locked,
        :interface_type,
        :auth,
        :mac_address,
        :duid,
        :network_id,
        :ipv4_config,
        :ipv4_address,
        :ipv6_config,
        :ipv6_address,
      ],
    )

    place = Place.find_or_initialize_by(permitted_params[:place])

    hardware = Hardware.find_or_initialize_by(permitted_params[:hardware])

    operating_system = if permitted_params[:operating_system][:os_category_id].present?
                         OperatingSystem.find_or_initialize_by(permitted_params[:operating_system])
                       end

    permitted_params.except(:place, :hardware, :operating_system).merge(
      place: place,
      hardware: hardware,
      operating_system: operating_system,
    )
  end

  private def authorize_node
    authorize Node
  end
end
