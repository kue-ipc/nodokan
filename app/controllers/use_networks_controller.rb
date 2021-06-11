class UseNetworksController < ApplicationController
  before_action :set_user
  before_action :set_network

  def create
    respond_to do |format|
      if @user.add_use_network(@network, manage: params[:manage])
        format.html { redirect_to @user, notice: 'ネットワークを紐付けました。' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { redirect_to @user, alert: 'ネットワークの紐付けに失敗しました。。' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.add_use_network(@network, manage: params[:manage])
        format.html { redirect_to @user, notice: 'ネットワークの紐付けを更新しました。' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { redirect_to @user, alert: 'ネットワークの紐付けの更新に失敗しました。。' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @user.remove_use_network(@network)
        format.html { redirect_to @user, notice: 'ネットワークの紐付けを解除しました。' }
        format.json { head :no_content }
      else
        format.html { redirect_to @user, alert: 'ネットワークの紐付けの解除に失敗しました。。' }
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
