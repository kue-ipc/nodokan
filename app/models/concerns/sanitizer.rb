module Sanitizer
  extend ActiveSupport::Concern

  class_methods do
    def sanitize(html, options = {})
      sanitize_helper.sanitize(html, options)
    end

    def sanitize_helper
      @sanitize_helper ||= Class.new do
        include ActionView::Helpers::SanitizeHelper
      end.new
    end
  end
end
