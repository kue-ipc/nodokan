module I18nHelper
  def t_enums(attr, model = nil, keys: nil)
    keys ||= model_class(model).__send__(attr.to_s.pluralize).keys
    keys.index_with { |key| t_enum(key, attr) }
  end

  def t_enum(value, attr)
    t(value, scope: [:activerecord, :enums, attr])
  end

  def t_bitwises(attr, model = nil, keys: nil)
    keys ||= model_class(model).__send__(attr.to_s.pluralize).keys
    keys.index_with { |key| t_bitwise(key, attr) }
  end

  def t_bitwise(value, attr)
    t(value, scope: [:activerecord, :bitwises, attr])
  end

  def t_floor(number)
    if number.zero?
      t("helpers.floor.zero")
    elsif number == 1
      t("helpers.floor.one")
    elsif number > 1
      t("helpers.floor.positive", number: number)
    else
      t("helpers.floor.negative", number: - number)
    end
  end
end
