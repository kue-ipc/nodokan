class OperatingSystemsController < ApplicationController
  before_action :set_operating_system, only: [:show, :update, :destroy]
  before_action :authorize_operating_system, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :target,
      :format,
      order: [:id, :os_category_id, :name, :nodes_count],
      condition: [:os_category_id, :name])

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @order = permitted_params[:order]

    @target = permitted_params[:target]&.intern
    @condition = permitted_params[:condition]

    @operating_systems = policy_scope(OperatingSystem).includes(:os_category)

    @operating_systems = @operating_systems.where(@condition.to_h) if @condition

    @operating_systems = @operating_systems.order(@order.to_h) if @order

    if @target
      if [:name].include?(@target)
        @operating_systems = @operating_systems
          .select(:os_category_id, @target, :description).distinct
      else
        raise ActionController::BadRequest,
          "[operating_systems#index] invalid target: #{@target}"
      end
    end

    unless permitted_params[:format] == "csv"
      @operating_systems = @operating_systems.page(@page).per(@per)
    end
  end

  def show
  end

  def create
    @operating_system = OperatingSystem.new(operating_system_params)
    authorize @operating_system

    if @operating_system.save
      render :show, status: :ok, location: @operating_system
    else
      render json: @operating_system.errors, status: :unprocessable_content
    end
  end

  def update
    @operating_system.assign_attributes(operating_system_params)
    same_operating_system = @operating_system.same

    if same_operating_system
      @operating_system.nodes.find_each do |node|
        same_operating_system.nodes << node
      end
      OperatingSystem.find(@operating_system.id).destroy
      # 再度取得しないとカウントがおかしい
      @operating_system = OperatingSystem.find(same_operating_system.id)
      render :show, status: :ok, location: @operating_system
    elsif @operating_system.save
      render :show, status: :ok, location: @operating_system
    else
      render json: @operating_system.errors, status: :unprocessable_content
    end
  end

  def destroy
    if @operating_system.destroy
      render head :no_content
    else
      render json: @operating_system.errors, status: :unprocessable_content
    end
  end

  private def authorize_operating_system
    authorize OperatingSystem
  end

  private def set_operating_system
    @operating_system = policy_scope(OperatingSystem).find(params[:id])
    authorize @operating_system
  end

  private def operating_system_params
    params.expect(
      operating_system: [:os_category_id,
      :name,
      :eol,
      :confirmed,
      :description,])
  end
end
