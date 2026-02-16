class SpecificNodeMailer < ApplicationMailer
  def apply
    @specific_node_application =
      SpecificNodeApplication.new(params[:specific_node_application])
    @user = User.find(@specific_node_application.user_id)
    @node = Node.find(@specific_node_application.node_id)

    mail subject: subject_with_site_title, to: @user.email, cc: Settings.admin.email
  end
end
