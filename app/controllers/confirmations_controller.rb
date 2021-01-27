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

  private
    # Only allow a list of trusted parameters through.
    def confirmation_params
      permitted_params = params.require(:confirmation).permit(
        :existence,
        :content,
        :os_update,
        :app_update,
        :security_update,
        :security_scan,
        security_software: [
          :os_category,
          :installation_method,
          :name,
        ]
      )

      security_software =
        if permitted_params[:security_software][:installation_method].present?
          SecuritySoftware.find_or_initialize_by(
            permitted_params[:security_software]
          )
        end

      permitted_params.except(:security_software).merge(
        {
          security_software: security_software,
        }
      )
    end

    def check_and_save
      @confirmation.approved = true

      if Confirmation.existences[@confirmation.existence] >= 16
        @confirmation.content_unknown!
        @confirmation.os_update_unknown!
        @confirmation.app_update_unknown!
        @confirmation.security_update_unknown!
        @confirmation.security_scan_unknown!
        @confirmation.secruity_software_unknown!
        @confirmation.approved = fales
      elsif  Confirmation.contents[@confirmation.content] >= 16 ||
        Confirmation.os_updates[@confirmation.os_update] >= 16 ||
        Confirmation.app_updates[@confirmation.app_update] >= 16 ||
        Confirmation.security_updates[@confirmation.security_update] >= 16 ||
        Confirmation.security_scans[@confirmation.security_scan] >= 16
        @confirmation.approved = fales
      end

      @confirmation.confirmed_at = Time.current
      if @confirmation.approved
        @confirmation.expiration = Time.current + 396.days
      else
        @confirmation.expiration = Time.current + 30.days
      end

      if @confirmation.save
        if @confirmation.approved
          flash[:notice] = '確認が完了しました。確認の有効期間は396日です。約一年後に再度確認を実施してください。'
        else
          flash[:alert] = '確認は完了しましたが、確認内容、または、登録内容に不備があるため、確認の有効期間は30日です。指摘事項を修正し、一ヶ月以内に再度確認を実施してください。'
        end
      else
        flash[:alert] = '確認の処理に失敗しました。再度実行し直してください。'
      end

      redirect_to @node
    end
end
