class BulksController < ApplicationController
  include Page
  include Search

  before_action :set_bulk, only: [:show, :destroy]
  before_action :authorize_bulk, only: [:index]

  search_for Bulk

  # GET /bulks or /bulks.json
  def index
    set_page
    set_search
    @bulks = paginate(search_and_sort(policy_scope(Bulk)).includes(:user))
  end

  # GET /bulks/1 or /bulks/1.json
  def show
  end

  # GET /bulks/new
  def new
    @bulk = Bulk.new
  end

  # POST /bulks or /bulks.json
  def create
    @bulk = Bulk.new(bulk_params)
    @bulk.user = current_user unless current_user.admin?
    authorize @bulk

    respond_to do |format|
      if @bulk.save
        format.turbo_stream do
          flash.now.notice = t_success(@bulk, :import)
        end
        format.html do
          redirect_to bulk_url(@bulk), notice: t_success(@bulk, :import)
        end
        format.json { render :show, status: :created, location: @bulk }
      else
        format.html do
          # flash.now.alert = t_failure(@bulk, :import)
          render :new, status: :unprocessable_entity
        end
        format.json { render json: @bulk.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bulks/1 or /bulks/1.json
  def destroy
    if @bulk.destroy
      respond_to do |format|
        format.html do
          redirect_to bulks_url, notice: t_success(@bulk, :delete)
        end
        format.json { head :no_content }
      end
    else
      respond_to do |format|
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
    params.require(:bulk).permit(:user_id, :model, :status, :started_at,
      :stopped_at, :file, :result)
  end

  private def authorize_bulk
    authorize Bulk
  end
end
