class AdminMailerPreview < ActionMailer::Preview
  def job_failure
    AdminMailer.with(job: "TestJob", job_id: 0, time: Time.current, exception: "test exception message").job_failure
  end
end
