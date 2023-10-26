class AdminMailer < ApplicationMailer
  def job_failure
    @job = params[:job]
    @job_id = params[:job_id]
    @time = params[:time]
    @exception = params[:exception]
    mail to: Settings.admin.email
  end
end
