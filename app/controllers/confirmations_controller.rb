class ConfirmationsController < ApplicationController
  # POST /nodes/1/confirmation
  # POST /nodes/1/confirmation.json
  def create
    @node = Node.find(params[:node_id])
    authorize @node, :update?
    @confirmation = @node.build_confirmation(confirmation_params)

    check_and_save
  end

  # PATCH/PUT /nodes/1/confirmation
  # PATCH/PUT /nodes/1/confirmation.json
  def update
    @node = Node.find(params[:node_id])
    authorize @node, :update?
    @confirmation = @node.confirmation
    @confirmation.assign_attributes(confirmation_params)

    check_and_save
  end

  # Only allow a list of trusted parameters through.
  private def confirmation_params
    permitted_params = params.require(:confirmation).permit(
      :existence,
      :content,
      :os_update,
      :app_update,
      :security_update,
      :security_scan,
      security_software: [
        :os_category_id,
        :installation_method,
        :name,
      ],
    )

    security_software =
      if permitted_params.dig(:security_software, :installation_method).present?
        SecuritySoftware.find_or_initialize_by(permitted_params[:security_software])
      end

    permitted_params.except(:security_software).merge(security_software: security_software)
  end

  private def check_and_save
    @confirmation.check_and_approve!
    if @confirmation.save
      if @confirmation.approved
        flash[:notice] = t('messages.confirmaiton_approved')
      else
        flash[:alert] = t('messages.confirmaiton_unapproved')
      end
    else
      flash[:alert] = '確認の処理に失敗しました。再度実行し直してください。'
    end

    redirect_to @node
  end
end
