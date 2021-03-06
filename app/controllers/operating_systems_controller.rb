class OperatingSystemsController < ApplicationController
  before_action :authorize_operating_system, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :target,
      :format,
      order: [:id, :os_category_id, :name, :nodes_count],
      condition: [:os_category_id, :name],
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @order = permitted_params[:order]

    @target = permitted_params[:target]&.intern
    @condition = permitted_params[:condition]

    @operating_systems = policy_scope(OperatingSystem).includes(:os_category)

    @operating_systems = @operating_systems.where(@condition) if @condition

    @operating_systems = @operating_systems.order(@order.to_h) if @order

    if @target
      if [:name].include?(@target)
        @operating_systems = @operating_systems.select(:os_category_id, @target)
          .distinct
      else
        raise ActionController::BadRequest,
          "[operating_systems#index] invalid target: #{@target}"
      end
    end

    @operating_systems = @operating_systems.page(@page).per(@per) unless permitted_params[:format] == 'csv'
  end

  private

    def query_params
      params.permit
    end

    def authorize_operating_system
      authorize OperatingSystem
    end
end
