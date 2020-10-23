class PlacesController < ApplicationController
  before_action :authorize_node, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :sort,
      :target,
      :format,
      order: [:id, :area, :building, :floor, :room, :nodes_count],
      condition: [:area, :building, :floor, :room]
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @sort = permitted_params[:sort]
    @order = permitted_params[:order]

    @target = permitted_params[:target]
    @condition = permitted_params[:condition]

    @places = policy_scope(Place)

    @places = @places.where(@condition) if @condition

    if @target
      if ['area', 'building', 'room'].include?(@target)
        @places = @places.select(@target).distinct.page(params[:page])
      else
        raise ActionController::BadRequest,
          "[places#index] invalid target: #{@target}"
      end
    end

    if @order
      pp @order
      @places = @places.order(@order.to_h)
      # pp @order
      # @order.each do |key, value|
      #   pp key
      #   pp value
      # end
      pp @places
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

  def authorize_node
    authorize Node
  end
end
