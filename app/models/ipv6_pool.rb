require "ipaddr"

class Ipv6Pool < ApplicationRecord
  include Ipv6Config

  belongs_to :network

  validates :ipv6_first_address, allow_blank: false, ipv6_address: true
  validates :ipv6_last_address, allow_blank: false, ipv6_address: true

  def ipv6_first
    IPAddr.new_ntoh(ipv6_first_data)
  end

  def ipv6_first_address
    ipv6_first.to_s
  end

  def ipv6_first_address=(value)
    self.ipv6_first_data = IPAddr.new(value).hton
  end

  def ipv6_last
    IPAddr.new_ntoh(ipv6_last_data)
  end

  def ipv6_last_address
    ipv6_last.to_s
  end

  def ipv6_last_address=(value)
    self.ipv6_last_data = IPAddr.new(value).hton
  end

  def ipv6_range
    (ipv6_first..ipv6_last)
  end

  delegate :cover?, to: :ipv6_range
  delegate :each, to: :ipv6_range

  def identifier
    prefix =
      case ipv6_config
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
        logger.error("Unknown ipv6_config: #{ipv6_config}")
        "?"
      end
    "#{prefix}-#{ipv6_first_address}-#{ipv6_last_address}"
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
        logger.error("Invalid Ipv6Pool idetifier: #{str}")
        raise ArgumentError, "Invalid Ipv6Pool idetifier: #{str}"
      end

    Ipv6Pool.new(
      ipv6_config: config,
      ipv6_first_address: first,
      ipv6_last_address: last)
  end
end
