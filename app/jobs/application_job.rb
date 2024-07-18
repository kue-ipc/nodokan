class ApplicationJob < ActiveJob::Base
  # Number of records that can be operated at once
  LIMIT_SIZE = 1000

  # Automatically retry jobs that encountered a deadlock
  retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  # Send mail if job is failed
  rescue_from(StandardError) do |exception|
    if Rails.env.production?
      AdminMailer
        .with(job: self.class.name, job_id: job_id, time: Time.current,
          exception: exception.message)
        .job_failure.deliver_later
    end
    raise exception
  end

  def delete_records(relation, size: LIMIT_SIZE, once: false)
    if !size.positive?
      relation.delete_all
    elsif once
      relation.limit(size).delete_all
    else
      total = 0
      loop do
        count = relation.limit(size).delete_all
        total += count
        break if count < size

        logger.debug("Repeat deletion")
      end
      total
    end
  end
end
