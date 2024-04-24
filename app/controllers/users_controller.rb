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
    @users = search_and_sort(policy_scope(User)).includes(:auth_networks,
      :use_networks, :manage_networks)
    respond_to do |format|
      format.html do
        @users = paginate(@users)
      end
      format.json do
        @users = paginate(@users)
      end
      format.csv { @users }
    end
  end

  def show
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html do
          redirect_to @user, notice: t_success(@user, :update)
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html do
          flash.now.alert = t_failure(@user, :update)
          render :show
        end
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
        User.includes(:auth_networks, :use_networks,
          :manage_networks).find(params[:id])
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
      :auth_network_id)
  end
end
