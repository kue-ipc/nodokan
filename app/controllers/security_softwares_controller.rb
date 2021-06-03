class SecuritySoftwaresController < ApplicationController
  before_action :authorize_security_software, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :target,
      :format,
      order: [:id, :os_category_id, :installation_method, :name],
      condition: [:os_category_id, :installation_method, :name],
    )

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
        @security_softwares = @security_softwares.select(@target).distinct
      else
        raise ActionController::BadRequest,
          "[security_softwares#index] invalid target: #{@target}"
      end
    end

    unless permitted_params[:format] == 'csv'
      @security_softwares = @security_softwares.page(@page).per(@per)
    end
  end

  private

  def query_params
    params.permit
  end

  def authorize_security_software
    authorize SecuritySoftware
  end
end
