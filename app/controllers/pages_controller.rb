class PagesController < ApplicationController
  def top
    @networks = policy_scope(Network).all
  end

  def about
  end
end
