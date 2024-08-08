require "ipaddr"

class Ipv6Pool < ApplicationRecord
  include Ipv6Config
  include IpData

  has_paper_trail

  belongs_to :network

  validates :ipv6_last, comparison: {greater_than: :ipv6_first}
  validates :ipv6_last, comparison: {equal_to: :ipv6_mapped_last_from_first},
    if: :ipv6_mapped?

  validates :ipv6_config, exclusion: {in: ["dynamic", "reserved"]},
    unless: -> { network.ra_managed? || network.ra_assist? }
  validates :ipv6_config, exclusion: {in: ["mapped"]},
    unless: -> { network.has_ipv4? }

  validates_each :ipv6_first, :ipv6_last do |record, attr, value|
    unless record.network.ipv6_include?(value)
      record.errors.add(attr, I18n.t("errors.messages.out_of_network"))
    end
  end

  ipv4_data :ipv6_first
  ipv4_data :ipv6_last

  def ipv6_mapped_last_from_first
    IPAddr.new(ipv6_first.to_i + IPAddr::IN4MASK, Socket::AF_INET6)
  end

  def ipv6_range
    (ipv6_first..ipv6_last)
  end

  delegate :cover?, to: :ipv6_range
  delegate :each, to: :ipv6_range

  def identifier
    "#{ipv6_config_prefix}[#{ipv6_first_address}-#{ipv6_last_address}]"
  end

  def to_s
    identifier
  end

  def self.new_identifier(str)
    m = /\A(.)\[([\h:\.]+)-([\h:\.]+)\]\z/.match(str)
    if m.nil?
      logger.error("Invalid Ipv6Pool idetifier format: #{str}")
      raise ArgumentError, "Invalid Ipv6Pool idetifier format: #{str}"
    end

    prefix = m[1]
    first = m[2]
    last = m[3]

    config = ipv6_config_from_prefix(prefix)
    if config.nil?
      logger.error("Invalid Ipv6Pool idetifier prefix: #{str}")
      raise ArgumentError, "Invalid Ipv6Pool idetifier prefix: #{str}"
    end

    Ipv6Pool.new(
      ipv6_config: config,
      ipv6_first_address: first,
      ipv6_last_address: last)
  end
end
