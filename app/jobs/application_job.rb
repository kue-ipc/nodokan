class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  rescue_from(StandardError) do |exception|
    if Rails.env.production?
      AdminMailer
        .with(job: self.class.name, job_id: job_id, time: Time.current,
          exception: exception.message)
        .job_failure.deliver_later
    end
    raise exception
  end
end
