class SpecificNodeMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.specific_node_mailer.apply.subject
  #
  def apply
    @greeting = "Hi"

    mail to: "to@example.org"
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
