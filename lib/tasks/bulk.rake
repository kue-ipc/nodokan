namespace :bulk do
  desc "Clean Bulk"
  task clean: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      puts "run job with inline queue adapter"
      Rails.application.config.active_job.queue_adapter = :inline
    end
    puts "add job queue clean bulk, please see log"
    BulkCleanJob.perform_later
  end
end
