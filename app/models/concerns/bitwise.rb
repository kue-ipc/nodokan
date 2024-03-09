# TODO: 重複チェック等無しの簡易版、ActiveRecord::Enumのようなものを作るべき？
module Bitwise
  extend ActiveSupport::Concern

  class_methods do
    # rubocop: disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def bitwise(definitions)
      bitwise_prefix = definitions.delete(:_prefix)
      bitwise_suffix = definitions.delete(:_suffix)

      definitions.each do |name, values|
        name = name.intern
        unless values.is_a?(Hash)
          values = values.each_with_index
            .to_h { |value, idx| [value, 1 << idx] }
        end
        values = ActiveSupport::HashWithIndifferentAccess.new(values).freeze

        singleton_class.send(:define_method, name.to_s.pluralize) do
          values
        end

        define_method(name.to_s.pluralize) do
          if self[name].nil?
            nil
          elsif self[name].positive?
            values.select { |_, value|
              value.positive? && (self[name] & value).positive?
            }.keys
          else
            [values.key(self[name])].compact
          end
        end

        prefix =
          if bitwise_prefix == true
            "#{name}_"
          elsif bitwise_prefix
            "#{bitwise_prefix}_"
          end

        suffix =
          if bitwise_suffix == true
            "_#{name}"
          elsif bitwise_suffix
            "_#{bitwise_suffix}"
          end

        values.each do |key, value|
          attr_name = "#{prefix}#{key}#{suffix}"
          if value.positive?
            define_method("#{attr_name}?") do
              self[name].positive? && (self[name] & value).positive?
            end
            define_method("#{attr_name}!") do
              update!(name => [self[name], 0].max ^ value)
            end
            scope(attr_name,
              -> { where("#{name} > 0 AND #{name} & #{value} > 0") })
          else
            define_method("#{attr_name}?") do
              self[name] == value
            end
            define_method("#{attr_name}!") do
              update!(name => value)
            end
            scope(attr_name, -> { where(name => value) })
          end
        end
      end
    end
  end
end
