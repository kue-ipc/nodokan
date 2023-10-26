namespace :nic do
  desc "check nic"
  task check: :environment do
    if Rails.env.production?
      puts "add job queue all nics check, please see log"
      Nic.find_each do |nic|
        NicsConnectedAtJob.perform_later(nic)
      end
    else
      puts "run job queue all nics check, please wait..."
      Nic.find_each do |nic|
        NicsConnectedAtJob.perform_now(nic)
      end
    end
  end
end
