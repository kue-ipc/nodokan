# TODO: validatesの実装
module Flag
  extend ActiveSupport::Concern

  class_methods do
    def flag(name, values)
      name = name.to_s
      values = values.to_h.with_indifferent_access.freeze

      attribute name, :string

      define_method(name) do
        values.select { |attr, _c| self[attr] }.values.join.presence
      end

      define_method("#{name}=") do |str|
        values.each { |attr, c| self[attr] = !!str&.include?(c) }
      end
    end
  end
end
