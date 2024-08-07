# Hostname Validator
class HostnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value =~ /\A(?!-)[0-9a-z-]+(?<!-)\z/i

    record.errors.add(attribute,
      options[:message] || I18n.t("errors.messages.invalid_hostname"))
  end
end
