class ApplicationMailer < ActionMailer::Base
  layout "mailer"

  def subject_with_site_title
    "#{default_i18n_subject} - #{Settings.site.title || t(:nodokan)}"
  end
end
