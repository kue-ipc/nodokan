# TODO: validatesの実装
module Flag
  extend ActiveSupport::Concern
  include SafeChar

  class_methods do
    def flag(name, values, readonly: false)
      name = name.to_s
      values = normalize_values(values)
      values.each_value { |c| check_safe_char(c) }

      attribute name, :string

      define_method(name) do
        values.select { |attr, _c| self[attr] }.values.join.presence
      end

      return if readonly

      define_method("#{name}=") do |str|
        values.each { |attr, c| self[attr] = !!str&.include?(c) }
      end
    end


    private def normalize_values(values)
      values.to_h
        .transform_keys(&:intern)
        .transform_values { |c| c.to_s.strip.downcase }
        .with_indifferent_access
        .freeze
    end
  end
end
