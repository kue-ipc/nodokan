class BulksController < ApplicationController
  before_action :set_bulk, only: [:show, :edit, :update, :destroy]

  # GET /bulks or /bulks.json
  def index
    @bulks = Bulk.all
  end

  # GET /bulks/1 or /bulks/1.json
  def show
  end

  # GET /bulks/new
  def new
    @bulk = Bulk.new
  end

  # GET /bulks/1/edit
  def edit
  end

  # POST /bulks or /bulks.json
  def create
    @bulk = Bulk.new(bulk_params)

    respond_to do |format|
      if @bulk.save
        format.html do
          redirect_to bulk_url(@bulk), notice: "Bulk was successfully created."
        end
        format.json { render :show, status: :created, location: @bulk }
      else
        format.html do
          render :new, status: :unprocessable_entity
        end
        format.json { render json: @bulk.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bulks/1 or /bulks/1.json
  def update
    respond_to do |format|
      if @bulk.update(bulk_params)
        format.html do
          redirect_to bulk_url(@bulk), notice: "Bulk was successfully updated."
        end
        format.json { render :show, status: :ok, location: @bulk }
      else
        format.html do
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: @bulk.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bulks/1 or /bulks/1.json
  def destroy
    @bulk.destroy!

    respond_to do |format|
      format.html do
        redirect_to bulks_url, notice: "Bulk was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_bulk
      @bulk = Bulk.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bulk_params
      params.require(:bulk).permit(:user_id, :model, :status, :started_at,
        :stopped_at, :file, :result)
    end
end
