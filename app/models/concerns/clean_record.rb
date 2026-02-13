module CleanRecord
  extend ActiveSupport::Concern
  include Period

  class_methods do
    def retention_period
      @retention_period = nil if Rails.env.test?
      @retention_period ||= period(Settings.config.retention_period[model_name.param_key])
    end

    def nocompress_period
      @nocompress_period = nil if Rails.env.test?
      @nocompress_period ||= period(Settings.config.nocompress_period[model_name.param_key])
    end
  end
end
