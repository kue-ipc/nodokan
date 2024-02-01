class Ipv4Pool < ApplicationRecord
  include Ipv4Config
  include Enumerable

  belongs_to :network

  validates :ipv4_first_address, allow_blank: false, ipv4_address: true
  validates :ipv4_last_address, allow_blank: false, ipv4_address: true

  def ipv4_first
    IPAddr.new_ntoh(ipv4_first_data)
  end

  def ipv4_first_address
    ipv4_first.to_s
  end

  def ipv4_first_address=(value)
    self.ipv4_first_data = IPAddr.new(value).hton
  end

  def ipv4_last
    IPAddr.new_ntoh(ipv4_last_data)
  end

  def ipv4_last_address
    ipv4_last.to_s
  end

  def ipv4_last_address=(value)
    self.ipv4_last_data = IPAddr.new(value).hton
  end

  def ipv4_range
    (ipv4_first..ipv4_last)
  end

  delegate :cover?, to: :ipv4_range
  delegate :each, to: :ipv4_range

  def identifier
    prefix =
      case ipv4_config
      when "dynamic"
        "d"
      when "reserved"
        "r"
      when "static"
        "s"
      when "manual"
        "m"
      when "disabled"
        "!"
      else
        logger.error("Unknown ipv4_config: #{ipv4_config}")
        "?"
      end
    "#{prefix}-#{ipv4_first_address}-#{ipv4_last_address}"
  end

  def to_s
    identifier
  end

  def self.new_identifier(str)
    prefix, first, last = str.strip.downcase.split("-")

    config =
      case prefix
      when "d"
        "dynamic"
      when "r"
        "reserved"
      when "s"
        "static"
      when "m"
        "manual"
      when "!"
        "disabled"
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
