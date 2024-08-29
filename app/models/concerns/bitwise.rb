# TODO: 重複チェック等無しの簡易版、ActiveRecord::Enumのようなものを作るべき？
module Bitwise
  extend ActiveSupport::Concern

  class_methods do
    def bitwise(name = nil, values = nil, **options)
      if name
        unless values
          values = options
          options = {}
        end
        return _bitwise(name, values, **options)
      end

      definitions = options.slice!(:_prefix, :_suffix, :_scopes, :_default,
        :_instance_methods)
      options.transform_keys! { |key| :"#{key[1..]}" }
      definitions.each { |name, values| _bitwise(name, values, **options) }
    end

    # rubocop: disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    private def _bitwise(name, values, prefix: nil, suffix: nil, scopes: true,
      instance_methods: true, validate: false)

      name = name.intern
      unless values.is_a?(Hash)
        values = values.each_with_index
          .to_h { |value, idx| [value, 1 << idx] }
      end
      values = values.with_indifferent_access.freeze

      singleton_class.send(:define_method, name.to_s.pluralize) do
        values
      end

      define_method(name.to_s.pluralize) do
        if self[name].nil?
          nil
        elsif self[name].positive?
          values.select do |_, value|
            value.positive? && (self[name] & value).positive?
          end.keys
        else
          [values.key(self[name])].compact
        end
      end

      attr_prefix =
        if prefix == true
          "#{name}_"
        elsif prefix
          "#{prefix}_"
        end

      attr_suffix =
        if suffix == true
          "_#{name}"
        elsif suffix
          "_#{suffix}"
        end

      values.each do |key, value|
        attr_name = "#{attr_prefix}#{key}#{attr_suffix}"
        if value.positive?
          if instance_methods
            define_method("#{attr_name}?") do
              self[name].positive? && (self[name] & value).positive?
            end
            define_method("#{attr_name}!") do
              update!(name => [self[name], 0].max ^ value)
            end
          end
          if scopes
            scope(attr_name,
              -> { where("#{name} > 0 AND #{name} & #{value} > 0") })
          end
        else
          if instance_methods
            define_method("#{attr_name}?") do
              self[name] == value
            end
            define_method("#{attr_name}!") do
              update!(name => value)
            end
          end
          scope(attr_name, -> { where(name => value) }) if scopes
        end
      end

      # TODO: valideteの実装
      # if validate
      # end
    end
  end
end
