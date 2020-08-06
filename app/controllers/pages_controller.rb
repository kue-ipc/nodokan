class PagesController < ApplicationController
  def top
    @subnetworks = policy_scope(Subnetwork).all
  end

  def about
  end
end
