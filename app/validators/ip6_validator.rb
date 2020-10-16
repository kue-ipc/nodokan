require 'ipaddr'

# IPv6 Address Validator
class Ip6Validator < ActiveModel::EachValidator
  PATTERN_STR = '(?:[\\dA-Fa-f]{0,4}:){1,7}' \
    '(?:[\\dA-Fa-f]{1,4}|(?:\\d{1,3}\\.){3}\\d{1,3}|:)'
  PATTERN = /\A#{PATTERN_STR}\z/

  def validate_each(record, attribute, value)
    unless value =~ PATTERN
      record.errors[attribute] << (options[:message] || 'はIPv6アドレスではありません。')
    end
    IPAddr.new(value)
  rescue IPAddr::InvalidAddressError
    record.errors[attribute] << (options[:message] || 'はIPv6アドレスではありません。')
  end
end
