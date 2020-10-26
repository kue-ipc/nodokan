class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update]
  before_action :authorize_user, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :format,
      order: [:id, :username, :email, :fullname, :role],
      condition: [:username, :email, :fullname, :role, :deleted]
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @order = permitted_params[:order]
    @condition = permitted_params[:condition]

    @users = policy_scope(User)

    @users = @users.where(@condition) if @condition

    @users = @users.order(@order.to_h) if @order

    @users = @users.page(@page).per(@per)
  end

  def show
  end

  def update
  end

  def sync
  end

  private

    def set_user
      @user = User.find(params[:id])
      authorize @user
    end

    def authorize_user
      authorize User
    end
end
