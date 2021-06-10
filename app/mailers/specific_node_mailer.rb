class SpecificNodeMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.specific_node_mailer.apply.subject
  #
  def apply
    @specific_node_application = SpecificNodeApplication.new(params[:specific_node_application])
    @user = User.find(@specific_node_application.user_id)
    @node = Node.find(@specific_node_application.node_id)
    mail subect: '特定端末申請', to: @user.email, bcc: Settings.admin_email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.specific_node_mailer.notify_change.subject
  #
  def notify_change
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
