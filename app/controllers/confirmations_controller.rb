class ConfirmationsController < ApplicationController
  include ConfirmationParameter

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
    permitted_params = params.expect(confirmation: [
      :existence,
      :content,
      :os_update,
      :app_update,
      :software,
      :security_update,
      :security_scan,
      security_hardwares: [],
      security_software: [:os_category_id, :installation_method, :name],
    ])

    normalize_confirmation_params(permitted_params)
  end

  private def check_and_save
    @confirmation.check_and_approve!
    if @confirmation.save
      if @confirmation.approved
        flash.now.notice = t("messages.confirmation_approved",
          period: helpers.distance_of_time_in_words(@confirmation.expiration, Time.current))
      else
        flash.now.alert = t("messages.confirmation_unapproved",
          period: helpers.distance_of_time_in_words(@confirmation.expiration, Time.current))
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
