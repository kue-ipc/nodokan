# TODO: 重複チェック等無しの簡易版、ActiveRecord::Enumのようなものを作るべき？
module Bitwise
  extend ActiveSupport::Concern

  class_methods do
    # rubocop: disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
    def bitwise(name, values, prefix: nil, suffix: nil, scopes: true, instance_methods: true, validate: false)
      name = name.intern
      values =
        if values.is_a?(Hash)
          values.with_indifferent_access.freeze
        else
          values.each_with_index.to_h { |value, idx| [value, 1 << idx] }.with_indifferent_access.freeze
        end

      singleton_class.send(:define_method, name.to_s.pluralize) do
        values
      end

      singleton_class.send(:define_method, "#{name}_bitwise_to_list") do |bits|
        self.bitwise_to_list(bits, values)
      end

      singleton_class.send(:define_method, "#{name}_list_to_bitwise") do |list|
        self.list_to_bitwise(list, values)
      end

      define_method(name.to_s.pluralize) do
        self.class.bitwise_to_list(self[name], values)
      end

      attr_prefix =
        case prefix
        in nil | false
          ""
        in true
          "#{name}_"
        in String | Symbol
          "#{prefix}_"
        end

      attr_suffix =
        case suffix
        in nil | false
          ""
        in true
          "_#{name}"
        in String | Symbol
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
            scope(attr_name, -> { where(":name > 0 AND :name & :value > 0", name:, value:) })
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

    # NOTE: どれにもマッチしない場合は、nilを返すべきか？
    def list_to_bitwise(list, map)
      return if list.nil?

      bits = 0
      map.slice(*list).each_value do |value|
        if value.positive?
          bits |= value
        else
          bits = value
          break
        end
      end
      bits
    end

    def bitwise_to_list(bits, map)
      if bits.nil?
        nil
      elsif bits.positive?
        map.select { |_, v| v.positive? && (bits & v).positive? }.keys
      else
        [map.key(bits)].compact
      end
    end
  end
end
