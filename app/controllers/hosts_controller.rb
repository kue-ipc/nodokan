class HostsController < ApplicationController
  include Page
  include Search

  before_action :set_node

  search_for Node

  # GET /nodes/1/host
  def show
  end

  # GET /nodes/1/host/new
  def new
    @host = Node.new
    set_page
    set_search
    @hosts = paginate(search_and_sort(policy_scope(Node)).includes(:nics))
  end

  # GET /hosts/1/host/edit
  def edit
    set_page
    set_search
    @hosts = paginate(search_and_sort(policy_scope(Node)).includes(:nics))
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
