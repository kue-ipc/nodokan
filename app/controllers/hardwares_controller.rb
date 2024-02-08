class HardwaresController < ApplicationController
  before_action :set_hardware, only: [:show, :update, :destroy]
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
      condition: [:device_type_id, :maker, :product_name, :model_number])

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

    return if permitted_params[:format] == "csv"

    @hardwares = @hardwares.page(@page).per(@per)
  end

  def show
  end

  def create
    @hardware = Hardware.new(hardwrae_params)
    authorize @hardware

    if @hardware.save
      render :show, status: :ok, location: @hardware
    else
      render json: @hardware.errors, status: :unprocessable_entity
    end
  end

  def update
    @hardware.assign_attributes(hardware_params)
    same_hardware = @hardware.same

    if same_hardware
      @hardware.nodes.find_each do |node|
        same_hardware.nodes << node
      end
      Hardware.find(@hardware.id).destroy
      # 再度取得しないとカウントがおかしい
      @hardware = Hardware.find(same_hardware.id)
      render :show, status: :ok, location: @hardware
    elsif @hardware.save
      render :show, status: :ok, location: @hardware
    else
      render json: @hardware.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @hardware.destroy
      render head :no_content
    else
      render json: @hardware.errors, status: :unprocessable_entity
    end
  end

  private def set_hardware
    @hardware = policy_scope(Hardware).includes(:device_type).find(params[:id])
    authorize @hardware
  end

  private def authorize_hardware
    authorize Hardware
  end

  private def hardware_params
    params.require(:hardware).permit(
      :device_type_id,
      :maker,
      :product_name,
      :model_number,
      :confirmed)
  end
end
