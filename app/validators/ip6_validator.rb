require 'ipaddr'

# IPv6 Address Validator
class Ip6Validator < ActiveModel::EachValidator
  PATTERN_STR = '(?:[\\dA-Fa-f]{0,4}:){1,7}' \
    '(?:[\\dA-Fa-f]{1,4}|(?:\\d{1,3}\\.){3}\\d{1,3}|:)'.freeze
  PATTERN = /\A#{PATTERN_STR}\z/.freeze

  def validate_each(record, attribute, value)
    puts '-------'
    pp value
    unless value =~ PATTERN && IPAddr.new(value).ipv6?
      record.errors[attribute] << (options[:message] ||
        'IPv6アドレスではありません。')
    end
  rescue IPAddr::InvalidAddressError
    record.errors[attribute] << (options[:message] ||
      'IPv6アドレスではありません。')
  end
end
