class HostsController < ApplicationController
  include Search

  before_action :set_node

  search_for Node

  # GET /nodes/1/host
  def show
  end

  # GET /nodes/1/host/new
  def new
    set_search
    @hosts = search(policy_scope(Node)).includes(:nics)
  end

  # GET /nodes/1/host/edit
  def edit
    set_search
    @hosts = search(policy_scope(Node)).includes(:nics)
  end

  # POST /nodes/1/host
  def create
    @node.host = Node.find(host_params[:id])
    render :show
  end

  # PATCH/PUT /nodes/1/host
  def update
    @node.host = Node.find(host_params[:id])
    render :show
  end

  # DELETE /nodes/1/host
  def destroy
    @node.host_id = nil
    render :show
  end

  private def set_node
    @node =
      if params[:node_id] == "new"
        Node.new(user: current_user)
      else
        Node.find(params[:node_id])
      end
    authorize @node
  end

  private def host_params
    params.expect(host: [:id])
  end
end
