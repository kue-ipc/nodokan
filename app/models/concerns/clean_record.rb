module CleanRecord
  extend ActiveSupport::Concern
  include Period

  class_methods do
    def retention_period
      @retention_period = nil unless Rails.env.production?
      @retention_period ||= period(Settings.config.retention_period[model_name.param_key])
    end

    def nocompress_period
      @nocompress_period = nil unless Rails.env.production?
      @nocompress_period ||= period(Settings.config.nocompress_period[model_name.param_key])
    end
  end
end
