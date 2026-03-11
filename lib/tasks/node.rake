require "json"

namespace :node do
  desc "Check node"
  task check: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      puts "run job with inline queue adapter"
      Rails.application.config.active_job.queue_adapter = :inline
    end
    puts "add job queue kea check, please see log"
    NodeCheckAllJob.perform_later
  end
end
