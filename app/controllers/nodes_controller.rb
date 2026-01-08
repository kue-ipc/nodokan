class NodesController < ApplicationController
  include Search

  include NodeParameter

  before_action :set_node, only: [:show, :edit, :update, :destroy, :transfer]
  before_action :authorize_node, only: [:index]

  search_for Node

  # GET /nodes
  # GET /nodes.json
  # GET /nodes.csv
  def index
    set_search
    @nodes = search(policy_scope(Node)).includes(:user, :place, :hardware,
      :operating_system, :confirmation, nics: :network)
  end

  # GET /nodes/1
  # GET /nodes/1.json
  def show
  end

  # GET /nodes/new
  def new
    new_nic_params = {}
    if (network = current_user.default_network)
      new_nic_params.merge!({network_id: network.id, auth: network.auth,
      ipv4_config: (Nic.ipv4_configs.keys & network.ipv4_configs).first,
      ipv6_config: (Nic.ipv6_configs.keys & network.ipv6_configs).first,})
    end
    nic = Nic.new(**new_nic_params)

    @node = Node.new(
      place: Place.new,
      hardware: Hardware.new,
      operating_system: OperatingSystem.new,
      nics: [nic],
      user: current_user)
    @node.node_type = "mobile" if current_user.guest?
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
        format.json { render json: @node.errors, status: :unprocessable_content }
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
        format.json { render json: @node.errors, status: :unprocessable_content }
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
        format.json { render json: @node.errors, status: :unprocessable_content }
      elsif @node.destroy
        if current_user.id == @node.user_id
          # nodes_countが変更されているため、reloadする。
          current_user.reload
        end
        format.turbo_stream do
          flash.now.notice = t_success(@node, :delete)
        end
        format.html do
          redirect_to nodes_url, notice: t_success(@node, :delete)
        end
        format.json { head :no_content }
      else
        format.html do
          redirect_to @node, alert: t_failure(@node, :delete)
        end
        format.json { render json: @node.errors, status: :unprocessable_content }
      end
    end
  end

  # POST /nodes/1/tranfer
  def transfer
    permitted_params = params.permit(:username, :note)
    user = User.find_by(username: permitted_params[:username])
    note = permitted_params[:note]

    if user.nil?
      respond_to do |format|
        format.html do
          redirect_to @node, alert: t("errors.messages.not_found_user")
        end
        format.json do
          errors = {username: t("errors.messages.not_found_user")}
          render json: errors, status: :unprocessable_content
        end
      end
    elsif user.guest?
      respond_to do |format|
        format.html do
          redirect_to(@node,
            alert: t("errors.messages.cannot_transfer_to_guest"))
        end
        format.json do
          errors = {username: t("errors.messages.cannot_transfer_to_guest")}
          render json: errors, status: :unprocessable_content
        end
      end
    else
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
            redirect_to nodes_path, notice: t_success(@node, :transfer)
          end
          format.json { render :show, status: :ok, location: @node }
        else
          format.html do
            redirect_to @node, alert: t_failure(@node, :transfer)
          end
          format.json do
            render json: @node.errors, status: :unprocessable_content
          end
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
    permitted_params = params.expect(
      node: [:name,
      :hostname,
      :domain,
      :duid,
      :node_type,
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
      nics_attributes: [[
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
      ]],
    ])

    normalize_node_params(permitted_params)
  end

  private def authorize_node
    authorize Node
  end
end
