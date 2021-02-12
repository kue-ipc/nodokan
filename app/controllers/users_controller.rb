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

  def create
    @user = User.new(user_params)

    if @user.authorizable? && @user.sync_ldap! && @user.save
      redirect_to users_path, notice: '成功'
    else
      redirect_to users_path, alert: '失敗'
    end
  end

  def update
  end

  def sync
  end

  private

    def set_user
      @user =
        if params[:id]
          User.includes(:networks).find(params[:id])
        else
          current_user
        end
      authorize @user
    end

    def authorize_user
      authorize User
    end
end
