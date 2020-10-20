class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def top
    unless user_signed_in?
      render 'devise/sessions/new'
      return
    end

    @non_confirmed_nodes = policy_scope(Node).where(confirmed_at: nil)
    @networks = policy_scope(Network).all
  end

  def about
  end
end
