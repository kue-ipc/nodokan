# Time zone
Rails.application.configure do
  config.time_zone = 'Osaka'
  config.active_record.default_timezone = :local
end
