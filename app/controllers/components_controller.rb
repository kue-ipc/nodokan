class ComponentsController < ApplicationController
  include Page
  include Search

  before_action :set_node
  before_action :set_component, only: [:show, :update, :destroy]

  search_for Node

  # GET /nodes/1/components
  def index
  end

  # GET /nodes/1/components/1
  def show
  end

  # GET /nodes/1/components/new
  def new
    set_page
    set_search
    @components = paginate(search_and_sort(policy_scope(Node)).includes(:nics))
  end

  # PATCH/PUT /nodes/1/components/1
  def update
  end

  # DELETE /nodes/1/components/1
  def destroy
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

  private def set_component
    @component = Node.find(params[:id])
  end
end
