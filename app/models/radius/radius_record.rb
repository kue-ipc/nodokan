module Radius
  # rubocop:disable Rails/ApplicationRecord
  class RadiusRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: {writing: :radius}

    class << self
      def instance_method_already_implemented?(method_name)
        return true if ignore_dangerous_attribute_methods.include?(method_name)

        super
      end

      def ignore_dangerous_attribute_methods
        @ignore_dangerous_attribute_methods ||= %w[
          attribute
        ].flat_map { |attr_name| list_attribute_methods(attr_name) }
      end

      def list_attribute_methods(attr_name)
        # rubocop:disable Metrics/NestedPercentLiteral
        %w[
          %s
          %s=
          %s_before_type_cast
          %s_came_from_user?
          %s?
          %s_change
          %s_changed?
          %s_will_change!
          %s_was
          %s_previously_changed?
          %s_previous_change
          restore_%s!
          saved_change_to_%s?
          saved_change_to_%s
          %s_before_last_save
          will_save_change_to_%s?
          %s_change_to_be_saved
          %s_in_database
        ].map { |s| s % attr_name }
        # rubocop:enable Metrics/NestedPercentLiteral
      end
    end
  end
  # rubocop:enable Rails/ApplicationRecord
end
