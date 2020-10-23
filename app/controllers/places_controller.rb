class PlacesController < ApplicationController
  before_action :authorize_place, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :target,
      :format,
      order: [:id, :area, :building, :floor, :room, :nodes_count],
      condition: [:area, :building, :floor, :room]
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @order = permitted_params[:order]

    @target = permitted_params[:target]
    @condition = permitted_params[:condition]

    @places = policy_scope(Place)

    @places = @places.where(@condition) if @condition

    @places = @places.order(@order.to_h) if @order

    if @target
      if ['area', 'building', 'room'].include?(@target)
        @places = @places.select(@target).distinct.page(params[:page])
      else
        raise ActionController::BadRequest,
          "[places#index] invalid target: #{@target}"
      end
    end

    @places = @places.page(params[:page]).per(params[:per])
  end

  def edit
  end

  def update
  end

  def merge
  end

  private

  def authorize_place
    authorize Place
  end
end
