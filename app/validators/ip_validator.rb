require 'ipaddr'

# IPv4 Address Validator
class IpValidator < ActiveModel::EachValidator
  PATTERN_STR = '(?:\\d{1,3}\\.){3}\\d{1,3}'.freeze
  PATTERN = /\A#{PATTERN_STR}\z/.freeze

  def validate_each(record, attribute, value)
    unless value =~ PATTERN && IPAddr.new(value).ipv4?
      record.errors[attribute] << (options[:message] ||
        'IPアドレスではありません。')
    end
  rescue IPAddr::InvalidAddressError
    record.errors[attribute] << (options[:message] ||
      'IPアドレスではありません。')
  end
end
