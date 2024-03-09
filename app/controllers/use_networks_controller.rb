class UseNetworksController < ApplicationController
  before_action :set_user
  before_action :set_network

  def create
    respond_to do |format|
      if @user.add_use_network(@network, manage: params[:manage])
        format.html do
          redirect_to @user, notice: "ネットワークを紐付けました。"
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html do
          redirect_to @user, alert: "ネットワークの紐付けに失敗しました。"
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.add_use_network(@network, manage: params[:manage])
        format.html do
          redirect_to @user, notice: "ネットワークの紐付けを更新しました。"
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html do
          redirect_to @user, alert: "ネットワークの紐付けの更新に失敗しました。。"
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @user.remove_use_network(@network)
        format.html do
          redirect_to @user, notice: "ネットワークの紐付けを解除しました。"
        end
        format.json { head :no_content }
      else
        format.html do
          redirect_to @user, alert: "ネットワークの紐付けの解除に失敗しました。。"
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private def set_user
    @user = User.find(params[:user_id])
    authorize @user, :update?
  end

  private def set_network
    @network = Network.find(params[:id] || params[:network_id])
  end
end
