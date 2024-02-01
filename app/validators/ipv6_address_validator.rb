# IPv6 Address Validator
class Ipv6AddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value =~ /\A\[?\h*:[\h:.]+\]?\z/
      record.errors.add(attribute, options[:message] || I18n.t("errors.messages.invalid_ipv6_address"))
    elsif !IPAddr.new(value).ipv6?
      record.errors.add(attribute, options[:message] || I18n.t("errors.messages.not_ipv6"))
    end
  rescue IPAddr::InvalidAddressError
    record.errors.add(attribute, options[:message] || I18n.t("errors.messages.invalid_ip_address"))
  end
end
