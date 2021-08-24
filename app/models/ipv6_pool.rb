class Ipv6Pool < ApplicationRecord
  include Ipv6Config

  belongs_to :network

  validates :ipv6_first_address, allow_blank: false, ipv6: true
  validates :ipv6_last_address, allow_blank: false, ipv6: true

  delegate :ipv6_prefix_length, to: :network

  def ipv6_first
    @ipv6_first ||= IPAddress::IPv6.parse_hex(ipv6_first_data.unpack('H*').first, ipv6_prefix_length)
  end

  def ipv6_first_address
    @ipv6_first_address ||= ipv6_first.to_s
  end

  def ipv6_first_address=(value)
    @ipv6_first_address = value
    self.ipv6_first_data = @ipv6_first_address.presence &&
                           IPAddress::IPv6.new(@ipv6_first_address).data
  rescue ArgumentError
    self.ipv6_first_data = nil
  end

  def ipv6_last
    @ipv6_last ||= IPAddress::IPv6.parse_hex(ipv6_last_data.unpack('H*').first, ipv6_prefix_length)
  end

  def ipv6_last_address
    @ipv6_last_address ||= ipv6_last.to_s
  end

  def ipv6_last_address=(value)
    @ipv6_last_address = value
    self.ipv6_last_data = @ipv6_last_address.presence &&
                          IPAddress::IPv6.new(@ipv6_last_address).data
  rescue ArgumentError
    self.ipv6_last_data = nil
  end

  def ipv6_range
    @ipv6_range ||= Range.new(ipv6_first, ipv6_last)
  end

  def include?(addr)
    addr = IPAddress::IPv6.new(addr.to_s) unless addr.is_a?(IPAddress::IPv6)
    ipv6_range.cover?(addr)
  end

  delegate :cover?, to: :ipv6_range

  def identifier
    prefix =
      case ipv6_config
      when 'dynamic'
        'd'
      when 'reserved'
        'r'
      when 'static'
        's'
      when 'manual'
        'm'
      when 'disabled'
        '!'
      else
        logger.error("Unknown ipv6_config: #{ipv6_config}")
        '?'
      end
    "#{prefix}-#{ipv6_first_address}-#{ipv6_last_address}"
  end

  def to_s
    identifier
  end

  def self.new_identifier(str)
    prefix, first, last = str.strip.downcase.split('-')

    config =
      case prefix
      when 'd'
        'dynamic'
      when 'r'
        'reserved'
      when 's'
        'static'
      when 'm'
        'manual'
      when '!'
        'disabled'
      else
        logger.error("Invalid Ipv6Pool idetifier: #{str}")
        raise ArgumentError, "Invalid Ipv6Pool idetifier: #{str}"
      end

    Ipv6Pool.new(
      ipv6_config: config,
      ipv6_first_address: first,
      ipv6_last_address: last,
    )
  end
end
