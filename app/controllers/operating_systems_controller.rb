class OperatingSystemsController < ApplicationController
  before_action :authorize_operating_system, only: [:index]

  def index
    @target = params[:_t]

    @operating_systems =
      case @target
      when 'name'
        policy_scope(OperatingSystem).where(os_category: params[:os_category])
      else
        policy_scope(OperatingSystem).page(params[:page])
      end
  end

  private

    def query_params
      params.permit
    end

    def authorize_operating_system
      authorize OperatingSystem
    end
end
