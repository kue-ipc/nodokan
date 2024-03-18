class HostsController < ApplicationController
  before_action :set_node

  # GET /nodes/i/host/1 or /hosts/1.json
  def show
  end

  # GET /hosts/new
  def new
    @host = Node.new
  end

  # GET /hosts/1/edit
  def edit
  end

  # POST /hosts or /hosts.json
  def create
    @host = Host.new(host_params)

    respond_to do |format|
      if @host.save
        format.html do
          redirect_to host_url(@host), notice: "Host was successfully created."
        end
        format.json { render :show, status: :created, location: @host }
      else
        format.html do
          render :new, status: :unprocessable_entity
        end
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hosts/1 or /hosts/1.json
  def update
    respond_to do |format|
      if @host.update(host_params)
        format.html do
          redirect_to host_url(@host), notice: "Host was successfully updated."
        end
        format.json { render :show, status: :ok, location: @host }
      else
        format.html do
          render :edit, status: :unprocessable_entity
        end
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hosts/1 or /hosts/1.json
  def destroy
    @host.destroy!

    respond_to do |format|
      format.html do
        redirect_to hosts_url, notice: "Host was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private def set_node
    @node =
      if params[:node_id] == "new"
        Node.new
      else
        Node.find(params[:node_id])
      end
    authorize @node
  end

  private def host_params
    params.require(:host).permit(:id)
  end
end
