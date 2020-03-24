class ApplicationController < ActionController::Base
  include Pundit

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end

  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
end
