class HardwaresController < ApplicationController
  before_action :set_hardware, only: [:show, :edit, :update, :destroy]
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

    return if permitted_params[:format] == 'csv'

    @hardwares = @hardwares.page(@page).per(@per)
  end

  def show
  end

  def edit
  end

  def update
    @hardware.assign_attributes(permited_params)
    other_hardware = Hardware.find_by(
      device_type_id: @hardware.device_type_id,
      maker: @hardware.maker,
      product_name: @hardware.product_name,
      model_number: @hardware.model_name
    )

    if other_hardware
      respond_to do |format|
        if Node.update(@hardware.nodes_ids, hardware: other_hardware) &&
           @hardware.destroy
          format.html { redirect_to other_hardware,
            notice: '機器情報を統合しました。' }
          format.json { render :show, status: :ok, location: other_hardware }
        else
          format.html { render :edit }
          format.json { render json: @hardware.errors,
            status: :unprocessable_entity }
        end
      end
      return
    end

    respond_to do |format|
      if @hardware.save
        format.html { redirect_to @hardware,
          notice: '機器情報を更新しました。' }
        format.json { render :show, status: :ok, location: other_hardware }
      else
        format.html { render :edit }
        format.json { render json: @hardware.errors,
          status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @hardware.locked
      respond_to do |format|
        format.html { redirect_to hardwares_url, alert: 'ロックされた機器は削除できません。' }
        format.json { render json: @node.errors, status: :unprocessable_entity }
      end
    end

    @hardware.destroy
    respond_to do |format|
      format.html { redirect_to nodes_url, notice: 'Node was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private def set_hardware
    @hardware = plociy_scope(Hardware).includes(:device_type).find(params[:id])
    authorize @node
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
      :confirmed
    )
  end
end
