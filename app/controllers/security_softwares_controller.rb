class SecuritySoftwaresController < ApplicationController
  before_action :set_security_software, only: [:show, :update, :destroy]
  before_action :authorize_security_software, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :target,
      :format,
      order: [:id, :os_category_id, :installation_method, :name, :confirmations_count],
      condition: [:os_category_id, :installation_method, :name])

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @order = permitted_params[:order]

    @target = permitted_params[:target]&.intern
    @condition = permitted_params[:condition]

    @security_softwares = policy_scope(SecuritySoftware)

    @security_softwares = @security_softwares.where(@condition) if @condition

    @security_softwares = @security_softwares.order(@order.to_h) if @order

    if @target
      if [:name].include?(@target)
        @security_softwares = @security_softwares.select(@target, :description).distinct
      else
        raise ActionController::BadRequest,
          "[security_softwares#index] invalid target: #{@target}"
      end
    end

    @security_softwares = @security_softwares.page(@page).per(@per) unless permitted_params[:format] == "csv"
  end

  def show
  end

  def create
    @security_software = SecuritySoftware.new(security_software_params)
    authorize @security_software

    if @security_software.save
      render :show, status: :ok, location: @security_software
    else
      render json: @security_software.errors, status: :unprocessable_entity
    end
  end

  def update
    @security_software.assign_attributes(security_software_params)
    same_security_software = @security_software.same

    if same_security_software
      @security_software.confirmations.find_each do |confirmation|
        same_security_software.confirmations << confirmation
      end
      SecuritySoftware.find(@security_software.id).destroy
      # 再度取得しないとカウントがおかしい
      @security_software = SecuritySoftware.find(same_security_software.id)
      render :show, status: :ok, location: @security_software
    elsif @security_software.save
      render :show, status: :ok, location: @security_software
    else
      render json: @security_software.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @security_software.destroy
      render head :no_content
    else
      render json: @security_software.errors, status: :unprocessable_entity
    end
  end

  private def authorize_security_software
    authorize SecuritySoftware
  end

  private def set_security_software
    @security_software = policy_scope(SecuritySoftware).find(params[:id])
    authorize @security_software
  end

  private def security_software_params
    params.require(:security_software).permit(
      :area,
      :building,
      :floor,
      :room,
      :confirmed)
  end
end
