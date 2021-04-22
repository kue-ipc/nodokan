class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update]
  before_action :set_network_user, only: [:create_network, :delete_network]
  before_action :authorize_user, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :format,
      :query,
      order: [:username, :email, :fullname, :role],
      condition: [:username, :email, :fullname, :role, :deleted]
    )

    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @query = permitted_params[:query]
    @order = permitted_params[:order]
    @condition = permitted_params[:condition]

    @users = policy_scope(User).includes(:auth_network, :networks)

    if @query.present?
      @users = @users.where(
        'username LIKE :query OR email LIKE :query OR fullname LIKE :query',
        {query: "%#{@query}%"}
      )
    end

    @users = @users.where(@condition) if @condition

    @users = @users.order(@order.to_h) if @order

    unless ['csv', 'json'].include?(permitted_params[:format])
      @users = @users.page(@page).per(@per)
    end
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
    redirect =
      if params[:redirect_to] == 'index'
        users_path
      else
        @user
      end
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to redirect, notice: 'ユーザーを更新しました。'}
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render redirect }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def sync
  end

  def create_network
    @user.networks << Network.find(params[:network_id])
    respond_to do |format|
      format.html { redirect_to @user, notice: 'ネットワークの紐付けを追加しました。'}
      format.json { render :show, status: :ok, location: @user }
    end
  end

  def delete_network
    @user.networks.delete(Network.find(params[:network_id]))
    respond_to do |format|
      format.html { redirect_to @user, notice: 'ネットワークの紐付けを解除しました。' }
      format.json { head :no_content }
    end
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

    def set_network_user
      @user = User.includes(:networks).find(params[:id])
      # ネットワークの追加や削除は更新と同じ
      authorize @user, :update?
    end

    def authorize_user
      authorize User
    end

    def user_params
      params.require(:user).permit(
        :role,
        :auth_network_id
      )
    end
end
