class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update]
  before_action :authorize_user, only: [:index]

  def index
    permitted_params = params.permit(
      :page,
      :per,
      :query,
      condition: [:username, :email, :fullname, :role, :deleted],
      order: [:username, :email, :fullname, :role, :nodes_count]
    )
    @page = permitted_params[:page]
    @per = permitted_params[:per]
    @query = permitted_params[:query]
    @condition = permitted_params[:condition]
    @order = permitted_params[:order]

    @users = search_and_sort(policy_scope(User), query: @query, condition: @condition, order: @order)
      .includes(:auth_networks, :use_networks, :manage_networks)

    respond_to do |format|
      format.html { @users = @users.page(@page).per(@per) }
      format.json { @users = @users.page(@page).per(@per) }
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

  private def search_and_sort(model, query: nil, condition: {}, order: {})
    ransack_q = {}

    ransack_q["username_or_email_or_fullname_cont"] = query if query.present?

    if condition.present?
      condition.each do |k, v|
        case k
        when "username", "email", "fullname", "role"
          ransack_q["#{k}_eq"] = v
        when "deleted"
          ransack_q["#{k}_true"] = v
        end
      end
    end

    q = model.ransack(ransack_q)
    q.sorts = order.to_h.map { |k, v| "#{k} #{v}" } if order.present?
    q.result
  end
end
