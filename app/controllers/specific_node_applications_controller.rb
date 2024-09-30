class SpecificNodeApplicationsController < ApplicationController
  before_action :set_node, only: [:new, :create]

  def new
    @specific_node_application = SpecificNodeApplication.new
  end

  def create
    @specific_node_application =
      SpecificNodeApplication.new(specific_node_application_params)
    @specific_node_application.node_id = @node.id
    @specific_node_application.user_id = current_user.id
    if @specific_node_application.valid?
      SpecificNodeMailer.with(
        specific_node_application: @specific_node_application.serializable_hash)
        .apply.deliver_later
      redirect_to @node,
        notice: t("messages.has_applied_specific_node")
    else
      render :new
    end
  end

  private def set_node
    @node = Node.find(params[:node_id])
    authorize @node, :specific_apply?
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
      :note)
  end
end
