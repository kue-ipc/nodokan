class NoticeNodesMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_nodes_mailer.user.subject
  #
  def user
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_nodes_mailer.deleted_users.subject
  #
  def deleted_users
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notice_nodes_mailer.unowned.subject
  #
  def unowned
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
