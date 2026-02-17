class AdminMailer < ApplicationMailer
  default to: Settings.admin.email

  def job_failure
    @job = params[:job]
    @job_id = params[:job_id]
    @time = params[:time]
    @exception = params[:exception]
    mail subject: subject_with_site_title
  end
end
