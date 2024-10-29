class UsersController < ApplicationController
  include Search

  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user, only: [:index]

  search_for User

  # GET /users
  # GET /users.json
  # GET /users.csv
  def index
    set_search
    @users = search(policy_scope(User)).includes(:auth_networks, :use_networks)
  end

  def show
  end

  def edit
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
    # TODO: 未実装
  end

  private def set_user
    @user =
      if params[:id]
        User.includes(:auth_networks, :use_networks).find(params[:id])
      else
        current_user
      end
    authorize @user
  end

  private def authorize_user
    authorize User
  end

  private def user_params
    permitted_params = params.require(:user).permit(
      :limit,
      :unlimited,
      :role,
      :auth_network_id)
    if ActiveRecord::Type::Boolean.new.cast(permitted_params.delete(:unlimited))
      permitted_params[:limit] = nil
    end
    permitted_params
  end
end
