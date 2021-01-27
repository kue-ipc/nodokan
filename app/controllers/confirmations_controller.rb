class ConfirmationsController < ApplicationController
  before_action :set_confirmation, only: [:show, :edit, :update, :destroy]

  # GET /confirmations
  # GET /confirmations.json
  def index
    @confirmations = Confirmation.all
  end

  # GET /confirmations/1
  # GET /confirmations/1.json
  def show
  end

  # GET /confirmations/new
  def new
    @confirmation = Confirmation.new
  end

  # GET /confirmations/1/edit
  def edit
  end

  # POST /confirmations
  # POST /confirmations.json
  def create
    @node = Node.find(params[:node_id])
    authorize @node, :update?
    @confirmation = @node.build_confirmation(confirmation_params)

    @confirmation.confirmed_at = Time.current

    if @confirmation.save
      if @confirmation.approved
        flash[:notice] = '確認が完了しました。確認の有効期間は396日です。約一年後に再度確認を実施してください。'
      else
        flash[:alert] = '確認は完了しましたが、確認内容にセキュリティ上の問題がある、または、登録内容に不備があります。指摘事項を修正し、一ヶ月以内に再度確認を実施してください。'
      end
    else
      flash[:alert] = '確認の処理に失敗しました。再度実行し直してください。'
    end

    redirect_to @node

    # respond_to do |format|
    #   if @confirmation.save
    #     format.html { redirect_to @confirmation, notice: 'Confirmation was successfully created.' }
    #     format.json { render :show, status: :created, location: @confirmation }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @confirmation.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /confirmations/1
  # PATCH/PUT /confirmations/1.json
  def update
    respond_to do |format|
      if @confirmation.update(confirmation_params)
        format.html { redirect_to @confirmation, notice: 'Confirmation was successfully updated.' }
        format.json { render :show, status: :ok, location: @confirmation }
      else
        format.html { render :edit }
        format.json { render json: @confirmation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /confirmations/1
  # DELETE /confirmations/1.json
  def destroy
    @confirmation.destroy
    respond_to do |format|
      format.html { redirect_to confirmations_url, notice: 'Confirmation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_confirmation
      @confirmation = Confirmation.find(params[:id])
    end

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
end
