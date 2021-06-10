class SpecificNodeApplicationsController < ApplicationController
  before_action :set_node, only: [:new, :create]

  def new
    @specific_node_application = SpecificNodeApplication.new
  end

  def create
    @specific_node_application = SpecificNodeApplication.new(specific_node_application_params)
    @specific_node_application.node_id = @node.id
    @specific_node_application.user_id = current_user.id
    if @specific_node_application.valid?
      # TODO メーラー
      redirect_to @node, notice: '管理者に申請を送信しました。'
    else
      render :new
    end
end

  private def set_node
    @node = Node.find(params[:node_id])
    authorize @node, :update?
  end

  private def specific_node_application_params
    params.require(:specific_node_application).permit(
      :action,
      :reason,
      :rule_set,
      :rule_list,
      :external,
      :register_dns,
      :fqdn,
      :note,
    )
  end
end
