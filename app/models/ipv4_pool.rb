class Ipv4Pool < ApplicationRecord
  include Ipv4Config
  include Enumerable

  belongs_to :network

  validates :ipv4_first_address, allow_blank: false, ipv4: true
  validates :ipv4_last_address, allow_blank: false, ipv4: true

  delegate :ipv4_prefix_length, to: :network

  def ipv4_first
    @ipv4_first ||=
      IPAddress::IPv4.parse_data(ipv4_first_data, ipv4_prefix_length)
  end

  def ipv4_first_address
    @ipv4_first_address ||= ipv4_first.to_s
  end

  def ipv4_first_address=(value)
    @ipv4_first_address = value
    self.ipv4_first_data = @ipv4_first_address.presence &&
                           IPAddress::IPv4.new(@ipv4_first_address).data
  rescue ArgumentError
    self.ipv4_first_data = nil
  end

  def ipv4_last
    @ipv4_last ||=
      IPAddress::IPv4.parse_data(ipv4_last_data, ipv4_prefix_length)
  end

  def ipv4_last_address
    @ipv4_last_address ||= ipv4_last.to_s
  end

  def ipv4_last_address=(value)
    @ipv4_last_address = value
    self.ipv4_last_data = @ipv4_last_address.presence &&
                          IPAddress::IPv4.new(@ipv4_last_address).data
  rescue ArgumentError
    self.ipv4_last_data = nil
  end

  def ipv4_range
    @ipv4_range ||= Range.new(ipv4_first, ipv4_last)
  end

  delegate :cover?, to: :ipv4_range

  def each(&block)
    if block_given?
      ipv4_range.each(&block)
    else
      ipv4_range.each
    end
  end

  def identifier
    prefix =
      case ipv4_config
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
        logger.error("Unknown ipv4_config: #{ipv4_config}")
        '?'
      end
    "#{prefix}-#{ipv4_first_address}-#{ipv4_last_address}"
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
        logger.error("Invalid Ipv4Pool idetifier: #{str}")
        raise ArgumentError, "Invalid Ipv4Pool idetifier: #{str}"
      end

    Ipv4Pool.new(
      ipv4_config: config,
      ipv4_first_address: first,
      ipv4_last_address: last,
    )
  end
end
