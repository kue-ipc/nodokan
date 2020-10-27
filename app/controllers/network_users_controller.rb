class NetworkUsersController < ApplicationController
  before_action :set_network_user, only: [:show, :update, :destroy]

  def show
  end

  def create
    redirect = params.require(:redirect)

    @network_user = NetworkUser.new(network_user_params)
    authorize @network_user

    respond_to do |format|
      if @network_user.save
        format.html { redirect_to redirect, notice: '作成しました' }
        format.json { render :show, status: :created, location: @network_user }
      else
        format.html { redirect_to redirect, notice: '作成できませんでした。' }
        format.json { render json: @network_user.errors,
                             status: :unprocessable_entity }
      end
    end
  end

  def update
    redirect = params.require(:redirect)

    respond_to do |format|
      if @network_user.update(network_user_params)
        format.html { redirect_to redirect, notice: '更新しました。' }
        format.json { render :show, status: :ok, location: @network_user }
      else
        format.html { redirect_to redirect, notice: '更新できませんでした。' }
        format.json { render json: @network_user.errors,
                             status: :unprocessable_entity }
      end
    end
  end

  def destroy
    redirect = params.require(:redirect)

    @network_user.destroy
    respond_to do |format|
      format.html { redirect_to redirect, notice: '削除しました。'}
      format.json { head :no_content }
    end
  end

  private

    def network_user_params
      params.require(:network_user).permit(
        :user_id,
        :network_id,
        :available,
        :managable,
        :assigned
      )
    end

    def set_network_user
      @network_user = NetworkUser.find(params[:id])
      authorize @network_user
    end
end
