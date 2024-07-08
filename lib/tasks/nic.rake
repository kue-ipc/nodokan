namespace :nic do
  desc "check nic"
  task check: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      puts "run job with inline queue adapter"
      Rails.application.config.active_job.queue_adapter = :inline
    end
    puts "add job queue all nics check, please see log"
    NicsConnectedAtJob.perform_later
  end
end
