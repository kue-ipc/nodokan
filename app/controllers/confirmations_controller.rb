class ConfirmationsController < ApplicationController
  before_action :set_node

  # GET /nodes/1/confirmation
  def show
  end

  # GET /nodes/1/confirmation/new
  def new
  end

  # GET /nodes/1/confirmation/edit
  def edit
  end

  # POST /nodes/1/confirmation
  # POST /nodes/1/confirmation.json
  def create
    @confirmation = @node.build_confirmation(confirmation_params)

    check_and_save
  end

  # PATCH/PUT /nodes/1/confirmation
  # PATCH/PUT /nodes/1/confirmation.json
  def update
    @confirmation = @node.confirmation
    @confirmation.assign_attributes(confirmation_params)

    check_and_save
  end

  private def set_node
    @node = Node.find(params[:node_id])
    authorize @node, :confirm?
  end

  # Only allow a list of trusted parameters through.
  private def confirmation_params
    permitted_params = params.expect(
      confirmation: [:existence, :content, :os_update, :app_update, :software,
      :security_update, :security_scan,
      security_hardwares: [],
      security_software: [:os_category_id, :installation_method, :name],])

    security_hardware = list_to_bitwise(permitted_params[:security_hardwares],
      Confirmation.security_hardwares)

    security_software = permitted_params
      .dig(:security_software, :installation_method).presence &&
      SecuritySoftware.find_or_initialize_by(
        permitted_params[:security_software])

    permitted_params.except(:security_hardwares, :security_software)
      .merge(security_hardware:, security_software:)
  end

  private def list_to_bitwise(list, bitwises)
    return if list.nil?

    result = 0
    bitwises.slice(*list).each_value do |value|
      if value.positive?
        result |= value
      else
        result = value
        break
      end
    end
    result
  end

  private def check_and_save
    @confirmation.check_and_approve!
    if @confirmation.save
      if @confirmation.approved
        flash.now.notice = t("messages.confirmation_approved")
      else
        flash.now.alert = t("messages.confirmation_unapproved")
      end
    else
      logger.error("confirmation seve error: #{@confirmation.errors.to_json}")
      flash.now.alert = t_failure(@confirmation, :save)
    end

    respond_to do |format|
      format.turbo_stream do
      end
      format.html do
        redirect_to @node, **flash.to_hash
      end
      format.json do
        render json: @confirmation.errors, status: :unprocessable_content
      end
    end
  end
end
