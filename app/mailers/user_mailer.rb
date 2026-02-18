class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.notice_nodes.subject
  #
  def notice_nodes
    @user = params[:user]
    @node = params[:nodes]

    mail to: "to@example.org"
  end
end
