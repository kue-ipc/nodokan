class DeviceTypesController < ApplicationController
  before_action :set_device_type, only: [:show, :update, :destroy]
  before_action :authorize_device_type, only: [:index]

  def index
    @device_types = policy_scope(DeviceType)
    @device_types = @device_types.page(@page).per(@per)
  end

  def show
  end

  def create
    @device_type = DeviceType.new(device_type_params)
    authorize @device_type

    if @device_type.save
      render :show, status: :ok, location: @device_type
    else
      render json: @device_type.errors, status: :unprocessable_content
    end
  end

  def update
    if @device_type.update(device_type_params)
      render :show, status: :ok, location: @device_type
    else
      render json: @device_type.errors, status: :unprocessable_content
    end
  end

  def destroy
    if @device_type.destroy
      render head :no_content
    else
      render json: @device_type.errors, status: :unprocessable_content
    end
  end

  private def authorize_device_type
    authorize DeviceType
  end

  private def set_device_type
    @device_type = policy_scope(DeviceType).find(params[:id])
    authorize @device_type
  end

  private def device_type_params
    params.require(:device_type).permit(
      :name,
      :icon,
      :order,
      :locked,
      :description)
  end
end
