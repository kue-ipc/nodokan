class Ipv4Pool < ApplicationRecord
  include Ipv4Config
  include Enumerable

  belongs_to :network

  validates :ipv4_first_address, allow_blank: false, ipv4_address: true
  validates :ipv4_last_address, allow_blank: false, ipv4_address: true

  validates :ipv4_last, comparison: {greater_than: :ipv4_first}

  validates :ipv4_config, exclusion: {in: ["dynamic", "reserved"]},
    unless: -> { network.dhcp }

  validates_each :ipv4_first, :ipv4_last do |record, attr, value|
    network_range = record.network.ipv4_network&.to_range
    if !network_range&.cover?(value)
      record.errors.add(attr, I18n.t("errors.messages.out_of_network"))
    elsif network_range.begin == value
      record.errors.add(attr, I18n.t("errors.messages.network_address"))
    elsif network_range.end == value
      record.errors.add(attr, I18n.t("errors.messages.broadcast_address"))
    end
  end

  def ipv4_first
    ipv4_first_data && IPAddr.new_ntoh(ipv4_first_data)
  end

  def ipv4_first_address
    ipv4_first&.to_s
  end

  def ipv4_first=(value)
    self.ipv4_first_data = value&.hton
  end

  def ipv4_first_address=(value)
    self.ipv4_first = value.presence && IPAddr.new(value)
  rescue IPAddr::InvalidAddressError
    self.ipv4_first = nil
  end

  def ipv4_last
    ipv4_last_data && IPAddr.new_ntoh(ipv4_last_data)
  end

  def ipv4_last_address
    ipv4_last&.to_s
  end

  def ipv4_last=(value)
    self.ipv4_last_data = value&.hton
  end

  def ipv4_last_address=(value)
    self.ipv4_last = value.presence && IPAddr.new(value)
  rescue IPAddr::InvalidAddressError
    self.ipv4_last = nil
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
      ipv4_last_address: last)
  end
end
