class Ipv4PoolsController < ApplicationController
  # GET /ipv4_pools/new
  def new
    @ipv4_pool = Ipv4Pool.new
    authorize @ipv4_pool
  end
end
