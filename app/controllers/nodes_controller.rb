class NodesController < ApplicationController
  include Page
  include Search

  before_action :set_node, only: [:show, :edit, :update, :destroy, :transfer]
  before_action :authorize_node, only: [:index]

  search_for Node

  # GET /nodes
  # GET /nodes.json
  # GET /nodes.csv
  def index
    set_page
    set_search
    @nodes = search_and_sort(policy_scope(Node)).includes(:user, :place, :hardware, :operating_system, :confirmation,
      nics: :network)
    respond_to do |format|
      format.html { @nodes = paginate(@nodes) }
      format.json { @nodes = paginate(@nodes) }
      format.csv { @nodes }
    end
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
          os_category: @node.operating_system.os_category)
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
    @confirmation.existence = nil if @confirmation.existence_unknown?
    @confirmation.content = nil if @confirmation.content_unknown?
    @confirmation.os_update = nil if @confirmation.os_update_unknown?
    @confirmation.app_update = nil if @confirmation.app_update_unknown?
    @confirmation.software = nil if @confirmation.software_unknown?
    @confirmation.security_hardware = nil if @confirmation.security_hardware_unknown?
    @confirmation.security_update = nil if @confirmation.security_update_unknown?
    @confirmation.security_scan = nil if @confirmation.security_scan_unknown?
  end

  # GET /nodes/new
  def new
    nics =
      if current_user.usable_networks.count.zero?
        []
      else
        [Nic.new]
      end
    @node = Node.new(
      place: Place.new,
      hardware: Hardware.new,
      operating_system: OperatingSystem.new,
      nics: nics,
      user: current_user)
    authorize @node
  end

  # GET /nodes/1/edit
  def edit
  end

  # POST /nodes
  # POST /nodes.json
  def create
    create_node_params = node_params
    create_node_params[:nics_attributes]&.each_value { |nic| nic.delete(:id) }

    @node = Node.new(create_node_params)
    @node.user = current_user unless current_user.admin?
    authorize @node

    if params["add_nic"]
      @node.nics << Nic.new
      render :new
      return
    end

    number_count = 1
    @node.nics.each do |nic|
      nic.number = number_count
      manageable = nic.network.manageable?(current_user)
      nic.set_ipv4!(manageable)
      nic.set_ipv6!(manageable)

      number_count += 1
    end

    success = false

    Node.transaction do
      if !@node.save ||
         @node.errors.present? ||
         @node.place&.errors.present? ||
         @node.hardware&.errors.present? ||
         @node.operating_system&.errors.present? ||
         @node.nics.any? { |nic| nic.errors.present? }
        raise ActiveRecord::Rollback
      end

      success = true
    end

    respond_to do |format|
      if success
        format.html do
          redirect_to @node,
            notice: t("messages.success_action", model: @node.model_name.human, action: t("actions.register"))
        end
        format.json { render :show, status: :created, location: @node }
      else
        format.html do
          flash.now[:alert] = t("messages.failure_action", model: @node.model_name.human, action: t("actions.register"))
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

    if params["add_nic"]
      @node.nics << Nic.new
      render :edit
      return
    end

    number_count = 1
    @node.nics.each do |nic|
      nic.number = number_count
      manageable = nic.network.manageable?(current_user)
      nic.set_ipv4!(manageable)
      nic.set_ipv6!(manageable)

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
        format.html { redirect_to @node, notice: "端末を更新しました。" }
        format.json { render :show, status: :ok, location: @node }
      else
        format.html do
          flash.now[:alert] = "端末更新に失敗しました。"
          render :edit
        end
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nodes/1
  # DELETE /nodes/1.json
  def destroy
    respond_to do |format|
      if @node.specific
        format.html { redirect_to @node, alert: "特定端末は削除できません。特定端末の解除を申請してください。" }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      elsif @node.destroy
        format.html { redirect_to nodes_url, notice: "端末を削除しました。" }
        format.json { head :no_content }
      else
        format.html { redirect_to @node, alert: "端末の削除に失敗しました。" }
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
          ipv6_config: nic.ipv6_config)
      end)
  end

  # POST /nodes/1/tranfer
  def transfer
    user = User.find_by(username: params[:username])
    note = params[:note]
    if user
      @node.user = user
      @node.confirmation = nil
      if note.present?
        @node.note =
          if @node.note.blank?
            note
          elsif @node.note.end_with?("\n")
            @node.note + note
          else
            [@node.note, note].join("\n")
          end
      end
      respond_to do |format|
        if @node.save
          format.html { redirect_to nodes_path, notice: "端末を譲渡しました。" }
          format.json { render :show, status: :ok, location: @node }
        else
          format.html { redirect_to @node, alert: "移譲に失敗しました。" }
          format.json { render json: @node.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @node, alert: "該当するユーザーがいません。" }
        format.json { render json: {username: "該当のユーザーがいません。"}, status: :unprocessable_entity }
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
      :duid,
      :logical,
      :virtual_machine,
      :specific,
      :public,
      :dns,
      :note,
      :user_id,
      :host_id,
      :component_ids,
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
        :network_id,
        :ipv4_config,
        :ipv4_address,
        :ipv6_config,
        :ipv6_address,
      ])

    normalize_params(permitted_params)
  end

  private def normalize_params(permitted_params)
    corrected_params =
      if ActiveRecord::Type::Boolean.new.cast(permitted_params[:logical])
        {
          virtual_machine: false,
          host_id: nil,
          place: nil,
          hardware: nil,
          operating_system: nil,
        }
      elsif ActiveRecord::Type::Boolean.new.cast(permitted_params[:virtual_machine])
        {
          place: nil,
          hardware: find_or_new_hardware(permitted_params[:hardware]),
          operating_system: find_or_new_operating_system(permitted_params[:operating_system]),
        }
      else
        {
          host_id: nil,
          place: find_or_new_place(permitted_params[:place]),
          hardware: find_or_new_hardware(permitted_params[:hardware]),
          operating_system: find_or_new_operating_system(permitted_params[:operating_system]),
        }
      end

    permitted_params.merge(corrected_params)
  end

  private def find_or_new_place(place_params)
    return unless place_params&.values_at(:area, :building, :room)&.any?(&:present?)

    Place.find_or_initialize_by(place_params)
  end

  private def find_or_new_hardware(hardware_params)
    return unless hardware_params&.values&.any?(&:present?)

    Hardware.find_or_initialize_by(hardware_params)
  end

  private def find_or_new_operating_system(operating_system_params)
    return unless operating_system_params&.[](:os_category_id)&.present?

    OperatingSystem.find_or_initialize_by(operating_system_params)
  end

  private def authorize_node
    authorize Node
  end
end
