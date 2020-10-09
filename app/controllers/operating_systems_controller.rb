class OperatingSystemsController < ApplicationController
  before_action :authorize_operating_system, only: [:index]

  def index
    os_category = params[:os_category]
    if os_category
      if OperatingSystem.os_categories.include?(os_category)
        @operating_systems = policy_scope(OperatingSystem).where(os_category: os_category)
      else
        @operating_sysetms = []
      end
    else
      @operating_systems = policy_scope(OperatingSystem).all
    end
  end

  private

    def query_params
      params.permit()
    end

    def authorize_operating_system
      authorize OperatingSystem
    end
end
