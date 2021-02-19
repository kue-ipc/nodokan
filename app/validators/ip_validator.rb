# IPv4 Address Validator
class IpValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if IPAddress.valid_ipv4?(value)

    record.errors.add(attribute, options[:message] || t(:invalid_ip_address, scope: [:errors, :messages]))
  end
end
