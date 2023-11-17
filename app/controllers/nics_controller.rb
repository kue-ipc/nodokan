class NicsController < ApplicationController
  before_action :set_nic, only: [:show]

  # GET /nodes/1
  # GET /nodes/1.json
  def show
  end

  # Use callbacks to share common setup or constraints between actions.
  private def set_nic
    @nic = policy_scope(Nic)
      .includes(:node, :network)
      .find(params[:id])
    authorize @nic
  end
end
