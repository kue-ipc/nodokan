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
    @nodes = search_and_sort(policy_scope(Node)).includes(:user,
      :place, :hardware, :operating_system, :confirmation, nics: :network)
    respond_to do |format|
      format.html do
        @nodes = paginate(@nodes)
      end
      format.json do
        @nodes = paginate(@nodes)
      end
      format.csv { @nodes }
    end
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
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
    @node = Node.new(node_params)
    @node.user = current_user unless current_user.admin?
    authorize @node

    respond_to do |format|
      if @node.save
        format.turbo_stream do
          flash.now.notice = t_success(@node, :register)
        end
        format.html do
          redirect_to @node, notice: t_success(@node, :register)
        end
        format.json { render :show, status: :created, location: @node }
      else
        format.html do
          flash.now.alert = t_failure(@node, :register)
          render :new
        end
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nodes/1
  # PATCH/PUT /nodes/1.json
  def update
    respond_to do |format|
      if @node.update(node_params)
        format.turbo_stream do
          flash.now.notice = t_success(@node, :update)
        end
        format.html do
          redirect_to @node, notice: t_success(@node, :update)
        end
        format.json { render :show, status: :ok, location: @node }
      else
        format.html do
          flash.now.alert = t_failure(@node, :update)
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
        format.html do
          redirect_to @node,
            alert: t("errors.messages.not_delete_specific_node")
        end
        format.json { render json: @node.errors, status: :unprocessable_entity }
      elsif @node.destroy
        format.turbo_stream do
          flash.now.notice = t_success(@node, :delete)
        end
        format.html do
          redirect_to nodes_url, notice: t_success(@node, :delete)
        end
        format.json { head :no_content }
      else
        format.html do
          redirect_to @node, alert: "端末の削除に失敗しました。"
        end
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
          format.html do
            redirect_to nodes_path, notice: "端末を譲渡しました。"
          end
          format.json { render :show, status: :ok, location: @node }
        else
          format.html do
            redirect_to @node, alert: "移譲に失敗しました。"
          end
          format.json do
            render json: @node.errors, status: :unprocessable_entity
          end
        end
      end
    else
      respond_to do |format|
        format.html do
          redirect_to @node, alert: "該当するユーザーがいません。"
        end
        format.json do
          render json: {username: "該当のユーザーがいません。"},
            status: :unprocessable_entity
        end
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
      component_ids: [],
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
    delete_unchangable_params(permitted_params) unless current_user.admin?
    number = 1
    permitted_params[:nics_attributes]&.each_value do |nic_params|
      nic_params[:number] = number
      number += 1
    end

    if ActiveRecord::Type::Boolean.new.cast(permitted_params[:logical])
      permitted_params[:component_ids] = permitted_params[:component_ids]&.uniq
      permitted_params.merge!({
        virtual_machine: false,
        host_id: nil,
        place: nil,
        hardware: nil,
        operating_system: nil,
      })
    elsif ActiveRecord::Type::Boolean.new.cast(permitted_params[:virtual_machine])
      permitted_params[:component_ids] = []
      permitted_params[:place] = nil
    else
      permitted_params[:component_ids] = []
      permitted_params[:host_id] = nil
    end
    if permitted_params.key?(:place)
      permitted_params[:place] = find_or_new_place(permitted_params[:place])
    end
    if permitted_params.key?(:hardware)
      permitted_params[:hardware] = find_or_new_hardware(
        permitted_params[:hardware])
    end
    if permitted_params.key?(:operating_system)
      permitted_params[:operating_system] = find_or_new_operating_system(
        permitted_params[:operating_system])
    end
    permitted_params
  end

  private def delete_unchangable_params(permitted_params)
    permitted_params.delete(:specific)
    permitted_params.delete(:public)
    permitted_params.delete(:dns)
    permitted_params.delete(:user_id)
    permitted_params[:nics_attributes]&.each_value do |nic_params|
      delete_nic_params(nic_params)
    end
    permitted_params
  end

  private def delete_nic_params(nic_params)
    nic_params.delete(:locked)

    if nic_params[:id].blank?
      # new nic
      if nic_params[:network_id].present? &&
          !Network.find(nic_params[:network_id]).manageable?(current_user)
        # unmanageable
        nic_params[:ipv4_address] = nil
        nic_params[:ipv6_address] = nil
      end
      return
    end

    nic = Nic.find(nic_params[:id])

    if nic.locked?
      # delete all except of :id for locked nic
      nic_params.slice!(:id)
      return
    end

    network =
      if nic_params.key?(:network_id)
        nic_params[:network_id].presence && Network.find(nic_params[:network_id])
      else
        nic.network
      end

    return if network.nil?
    return if network.manageable?(current_user)

    if network.id == nic.network_id
      if !nic_params.key?(:ipv4_config) ||
          nic_params[:ipv4_config].to_s == nic.ipv4_config
        nic_params.delete(:ipv4_address) # use same ip
      else
        nic_params[:ipv4_address] = nil # reset ip address
      end
      if !nic_params.key?(:ipv6_config) ||
          nic_params[:ipv6_config].to_s == nic.ipv6_config
        nic_params.delete(:ipv6_address) # use same ip
      else
        nic_params[:ipv6_address] = nil # reset ip address
      end
    else
      # reset ip address
      nic_params[:ipv4_address] = nil
      nic_params[:ipv6_address] = nil
    end
    nic_params
  end

  private def find_or_new_place(place_params)
    unless place_params&.values_at(:area, :building, :room)&.any?(&:present?)
      return
    end

    Place.find_or_initialize_by(place_params)
  end

  private def find_or_new_hardware(hardware_params)
    return unless hardware_params&.values&.any?(&:present?)

    Hardware.find_or_initialize_by(hardware_params)
  end

  private def find_or_new_operating_system(operating_system_params)
    return if operating_system_params&.[](:os_category_id).blank?

    OperatingSystem.find_or_initialize_by(operating_system_params)
  end

  private def authorize_node
    authorize Node
  end
end
