# IPv4 Address Validator
class Ipv4AddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value !~ /\A\d+\.\d+\.\d+\.\d+\z/
      record.errors.add(attribute, options[:message] || I18n.t("errors.messages.invalid_ipv4_address"))
    elsif !IPAddr.new(value).ipv4?
      record.errors.add(attribute, options[:message] || I18n.t("errors.messages.not_ipv4"))
    end
  rescue IPAddr::InvalidAddressError
    record.errors.add(attribute, options[:message] || I18n.t("errors.messages.invalid_ip_address"))
  end
end
