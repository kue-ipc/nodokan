# FIXME: ガイド記載の方法ではうまくいかないため、SOより
#   https://stackoverflow.com/questions/66870657/
Rails.autoloaders.main.ignore("#{Rails.root}/app/serializers")
Dir[Rails.root.join("app/serializers/**/*.rb")].each { |f| require f }
Rails.application.config.active_job.custom_serializers << IpaddrSerializer
