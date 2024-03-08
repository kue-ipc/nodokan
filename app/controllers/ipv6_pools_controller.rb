class Ipv6PoolsController < ApplicationController
  # GET /ipv6_pools/new
  def new
    @ipv6_pool = Ipv6Pool.new
    authorize @ipv6_pool
  end
end
