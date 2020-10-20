class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def top
    unless user_signed_in?
      render 'devise/sessions/new'
    end
    @networks = policy_scope(Network).all
  end

  def about
  end
end
