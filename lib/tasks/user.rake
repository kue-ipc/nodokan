require "json"

namespace :user do
  desc "Sync users"
  task sync: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      puts "run job with inline queue adapter"
      Rails.application.config.active_job.queue_adapter = :inline
    end
    puts "add job queue user sync, please see log"
    UsersSyncJob.perform_later
  end

  desc "Clean users: destroy user who is deleted and has no node"
  task clean: :environment do
    puts "clean users ..."
    users = User.where(deleted: true, nodes_count: 0).destroy_all
    puts "detroied: #{users.count}"
  end
end
