namespace :radius do
  desc 'Check radius record'
  task check: :environment do
    if Rails.env.production?
      puts 'add job queue radius check, please see log'
      RadiusCheckAllJob.perform_later
    else
      puts 'run job queue radius check, please wait...'
      RadiusCheckAllJob.perform_now
    end
  end
end
