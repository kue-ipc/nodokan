class ApplicationMailer < ActionMailer::Base
  default from: Settings.mailer.options.from
  layout "mailer"
end
