class OsCategoriesController < ApplicationController
  before_action :set_os_category, only: [:show, :update, :destroy]
  before_action :authorize_os_category, only: [:index]

  def index
    @os_categories = policy_scope(OsCategory)
    @os_categories = @os_categories.page(@page).per(@per)
  end

  def show
  end

  def create
    @os_category = OsCategory.new(os_category_params)
    authorize @os_category

    if @os_category.save
      render :show, status: :ok, location: @os_category
    else
      render json: @os_category.errors, status: :unprocessable_entity
    end
  end

  def update
    if @os_category.update(os_category_params)
      render :show, status: :ok, location: @os_category
    else
      render json: @os_category.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @os_category.destroy
      render head :no_content
    else
      render json: @os_category.errors, status: :unprocessable_entity
    end
  end

  private def authorize_os_category
    authorize OsCategory
  end

  private def set_os_category
    @os_category = policy_scope(OsCategory).find(params[:id])
    authorize @os_category
  end

  private def os_category_params
    params.require(:os_category).permit(
      :name,
      :icon,
      :order,
      :locked,
      :description)
  end
end
