# FIXME: ガイド記載の方法ではうまくいかないため、SOより
#   https://stackoverflow.com/questions/66870657/
Rails.autoloaders.main.ignore("#{Rails.root.join('app/serializers')}")
Dir[Rails.root.join("app/serializers/**/*.rb")].each do |f|
  require f
end
Rails.application.config.active_job.custom_serializers << IpaddrSerializer
