class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def top
    render "devise/sessions/new" unless user_signed_in?
  end

  def about
  end

  def help_bulk
  end
end
