# IPv4 Address Validator
class Ipv4Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if IPAddress.valid_ipv4?(value)

    record.errors.add(attribute, options[:message] || I18n.t("errors.messages.invalid_ipv4_address"))
  end
end
