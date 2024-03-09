# DUID Validator
class DuidValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value =~ /\A\h{2}(?:[-:]\h{2})*\z/

    record.errors.add(attribute,
      options[:message] || I18n.t("errors.messages.invalid_duid"))
  end
end
