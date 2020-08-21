class OperatingSystemsController < ApplicationController
  before_action :authorize_operating_system, only: [:index]

  def index
    category = params[:category]
    if category
      if OperatingSystem.categories.include?(category)
        @operating_systems = policy_scope(OperatingSystem).where(category: category)
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
