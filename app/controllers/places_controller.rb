class PlacesController < ApplicationController
  before_action :set_place, only: [:show, :update, :destroy]
  before_action :authorize_place, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :target,
      :format,
      order: [:id, :area, :building, :floor, :room, :nodes_count],
      condition: [:area, :building, :floor, :room])

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @order = permitted_params[:order]

    @target = permitted_params[:target]&.intern
    @condition = permitted_params[:condition]

    @places = policy_scope(Place)

    @places = @places.where(@condition) if @condition

    @places = @places.order(@order.to_h) if @order

    if @target
      if [:area, :building, :room].include?(@target)
        @places = @places.select(@target).distinct
      else
        raise ActionController::BadRequest,
          "[places#index] invalid target: #{@target}"
      end
    end

    unless permitted_params[:format] == "csv"
      @places = @places.page(@page).per(@per)
    end
  end

  def show
  end

  def create
    @place = Place.new(place_params)
    authorize @place

    if @place.save
      render :show, status: :ok, location: @place
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end

  def update
    @place.assign_attributes(place_params)
    same_place = @place.same

    if same_place
      @place.nodes.find_each do |node|
        same_place.nodes << node
      end
      Place.find(@place.id).destroy
      # 再度取得しないとカウントがおかしい
      @place = Place.find(same_place.id)
      render :show, status: :ok, location: @place
    elsif @place.save
      render :show, status: :ok, location: @place
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @place.destroy
      render head :no_content
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end

  private def authorize_place
    authorize Place
  end

  private def set_place
    @place = policy_scope(Place).find(params[:id])
    authorize @place
  end

  private def place_params
    params.require(:place).permit(
      :area,
      :building,
      :floor,
      :room,
      :confirmed)
  end
end
