class HardwaresController < ApplicationController
  before_action :authorize_hardware, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :target,
      :format,
      order: [
        :id, :device_type_id, :maker, :product_name, :model_number,
        :nodes_count,
      ],
      condition: [:device_type_id, :maker, :product_name, :model_number]
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @order = permitted_params[:order]

    @target = permitted_params[:target]&.intern
    @condition = permitted_params[:condition]

    @hardwares = policy_scope(Hardware).includes(:device_type)

    @hardwares = @hardwares.where(@condition) if @condition

    @hardwares = @hardwares.order(@order.to_h) if @order

    if @target
      if [:maker, :product_name, :model_number].include?(@target)
        @hardwares = @hardwares.select(:device_type_id, @target).distinct
      else
        raise ActionController::BadRequest,
          "invalid target: #{@target}"
      end
    end

    unless permitted_params[:format] == 'csv'
      @hardwares = @hardwares.page(@page).per(@per)
    end
  end

  def edit
  end

  def update
  end

  private

  def authorize_hardware
    authorize Hardware
  end
end
