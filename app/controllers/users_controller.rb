class UsersController < ApplicationController
  include Page
  include Search

  before_action :set_user, only: [:show, :update]
  before_action :authorize_user, only: [:index]

  search_for User

  # GET /users
  # GET /users.json
  # GET /users.csv
  def index
    set_page
    set_search
    @users = search_and_sort(policy_scope(User)).includes(:auth_networks, :use_networks, :manage_networks)
    respond_to do |format|
      format.html { @users = paginate(@users) }
      format.json { @users = paginate(@users) }
      format.csv { @users }
    end
  end

  def show
  end

  def create
    @user = User.new(user_params)

    if @user.authorizable? && @user.sync_ldap! && @user.save
      redirect_to users_path, notice: "成功"
    else
      redirect_to users_path, alert: "失敗"
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "ユーザーを更新しました。" }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render @user }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def sync
    # TODO
  end

  private def set_user
    @user =
      if params[:id]
        User.includes(:auth_networks, :use_networks, :manage_networks).find(params[:id])
      else
        current_user
      end
    authorize @user
  end

  private def authorize_user
    authorize User
  end

  private def user_params
    params.require(:user).permit(
      :role,
      :auth_network_id
    )
  end
end
