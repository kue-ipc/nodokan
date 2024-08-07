# Domain Validator
class DomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value =~ /\A(?<name>(?!-)[0-9a-z-]+(?<!-))(?:\.\g<name>)*\z/i

    record.errors.add(attribute,
      options[:message] || I18n.t("errors.messages.invalid_domain"))
  end
end
