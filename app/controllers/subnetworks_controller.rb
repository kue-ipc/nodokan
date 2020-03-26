class SubnetworksController < ApplicationController
  before_action :set_subnetwork, only: [:show, :edit, :update, :destroy]

  # GET /subnetworks
  # GET /subnetworks.json
  def index
    @subnetworks = Subnetwork.all
  end

  # GET /subnetworks/1
  # GET /subnetworks/1.json
  def show
  end

  # GET /subnetworks/new
  def new
    @subnetwork = Subnetwork.new
  end

  # GET /subnetworks/1/edit
  def edit
  end

  # POST /subnetworks
  # POST /subnetworks.json
  def create
    @subnetwork = Subnetwork.new(subnetwork_params)

    respond_to do |format|
      if @subnetwork.save
        format.html { redirect_to @subnetwork, notice: 'Subnetwork was successfully created.' }
        format.json { render :show, status: :created, location: @subnetwork }
      else
        format.html { render :new }
        format.json { render json: @subnetwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subnetworks/1
  # PATCH/PUT /subnetworks/1.json
  def update
    respond_to do |format|
      if @subnetwork.update(subnetwork_params)
        format.html { redirect_to @subnetwork, notice: 'Subnetwork was successfully updated.' }
        format.json { render :show, status: :ok, location: @subnetwork }
      else
        format.html { render :edit }
        format.json { render json: @subnetwork.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subnetworks/1
  # DELETE /subnetworks/1.json
  def destroy
    @subnetwork.destroy
    respond_to do |format|
      format.html { redirect_to subnetworks_url, notice: 'Subnetwork was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subnetwork
      @subnetwork = Subnetwork.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subnetwork_params
      params.require(:subnetwork).permit(:name, :network_type_id, :vlan)
    end
end
