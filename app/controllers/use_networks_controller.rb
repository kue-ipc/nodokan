class UseNetworksController < ApplicationController
  before_action :set_user
  before_action :set_network

  def create
    respond_to do |format|
      if @user.add_use_network(@network, manage: params[:manage])
        format.html do
          redirect_to @user, notice: t_success(Assignment, :add)
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html do
          redirect_to @user, alert: t_failure(Assignment, :add)
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.add_use_network(@network, manage: params[:manage])
        format.html do
          redirect_to @user, notice: t_success(Assignment, :update)
        end
        format.json { render :show, status: :ok, location: @user }
      else
        format.html do
          redirect_to @user, alert: t_failure(Assignment, :update)
        end
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @user.remove_use_network(@network)
        format.html do
          redirect_to @user, notice: t_success(Assignment, :release)
        end
        format.json { head :no_content }
      else
        format.html do
          redirect_to @user, alert: t_failure(Assignment, :release)
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
