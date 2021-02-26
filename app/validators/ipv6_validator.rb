# IPv6 Address Validator
class Ipv6Validator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if IPAddress.valid_ipv6?(value)

    record.errors.add(attribute, options[:message] || I18n.t(:invalid_ipv6_address, scope: [:errors, :messages]))
  end
end
