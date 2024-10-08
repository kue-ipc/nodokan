class BulksController < ApplicationController
  include Search

  before_action :set_bulk, only: [:show, :destroy, :cancel]
  before_action :authorize_bulk, only: [:index]

  search_for Bulk

  # GET /bulks or /bulks.json
  def index
    set_search(order: {"id" => "desc"}, per: 20)
    @bulks = search(policy_scope(Bulk)).includes(:user)
  end

  # GET /bulks/1 or /bulks/1.json
  def show
  end

  # POST /bulks or /bulks.json or /bulks.turbo_stream
  def create
    @bulk = Bulk.new(bulk_params)
    @bulk.user = current_user
    @bulk.status = "waiting"
    authorize @bulk

    respond_to do |format|
      if @bulk.save
        format.turbo_stream do
          flash.now.notice = t_success(@bulk, :register)
        end
        format.html do
          redirect_to bulk_url(@bulk), notice: t_success(@bulk, :register)
        end
        format.json { render :show, status: :created, location: @bulk }
      else
        format.turbo_stream do
          flash.now.alert = t_failure(@bulk, :register)
        end
        format.html do
          flash.alert = t_failure(@bulk, :register)
          render :new, status: :unprocessable_entity
        end
        format.json { render json: @bulk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bulks/1/cancel or /bulks/1/cancel.json
  def cancel
    respond_to do |format|
      if @bulk.update(status: :cancel)
        format.turbo_stream do
          flash.now.notice = t_success(@bulk, :cancel)
        end
        format.html do
          redirect_to bulk_url(@bulk), notice: t_success(@bulk, :cancel)
        end
        format.json { render :show, status: :ok, location: @bulk }
      else
        @bulk.restore_status!
        format.turbo_stream do
          flash.now.alert = t_failure(@bulk, :cancel)
        end
        format.html do
          flash.alert = t_failure(@bulk, :cancel)
          render :show, status: :unprocessable_entity
        end
        format.json { render json: @bulk.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bulks/1 or /bulks/1.json
  def destroy
    if @bulk.destroy
      respond_to do |format|
        format.turbo_stream do
          flash.now.notice = t_success(@bulk, :delete)
        end
        format.html do
          redirect_to bulks_url, notice: t_success(@bulk, :delete)
        end
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now.alert = t_failure(@bulk, :delete)
        end
        format.html do
          redirect_to bulks_url, alert: t_failure(@bulk, :delete)
        end
        format.json { render json: @bulk.errors, status: :unprocessable_entity }
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  private def set_bulk
    @bulk = Bulk.find(params[:id])
    authorize @bulk
  end

  # Only allow a list of trusted parameters through.
  private def bulk_params
    params.require(:bulk).permit(:target, :input)
  end

  private def authorize_bulk
    authorize Bulk
  end
end
