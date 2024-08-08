class Ipv4Pool < ApplicationRecord
  include Ipv4Config
  include IpData

  has_paper_trail

  belongs_to :network

  validates :ipv4_last, comparison: {greater_than: :ipv4_first}

  validates :ipv4_config, exclusion: {in: ["dynamic", "reserved"]},
    unless: -> { network.dhcp }

  validates_each :ipv4_first, :ipv4_last do |record, attr, value|
    network = record.network
    if !network.ipv4_include?(value)
      record.errors.add(attr, I18n.t("errors.messages.out_of_network"))
    elsif value == network.ipv4_network
      record.errors.add(attr, I18n.t("errors.messages.network_address"))
    elsif value == network.ipv4_broadcast
      record.errors.add(attr, I18n.t("errors.messages.broadcast_address"))
    end
  end

  ipv4_data :ipv4_first
  ipv4_data :ipv4_last

  def ipv4_range
    (ipv4_first..ipv4_last)
  end

  delegate :cover?, to: :ipv4_range
  delegate :each, to: :ipv4_range

  def identifier
    "#{ipv4_config_prefix}[#{ipv4_first_address}-#{ipv4_last_address}]"
  end

  def to_s
    identifier
  end

  def self.new_identifier(str)
    m = /\A(.)\[([\d\.]+)-([\d\.]+)\]\z/.match(str)
    if m.nil?
      logger.error("Invalid Ipv4Pool idetifier format: #{str}")
      raise ArgumentError, "Invalid Ipv4Pool idetifier format: #{str}"
    end

    prefix = m[1]
    first = m[2]
    last = m[3]

    config = ipv4_config_from_prefix(prefix)
    if config.nil?
      logger.error("Invalid Ipv4Pool idetifier prefix: #{str}")
      raise ArgumentError, "Invalid Ipv4Pool idetifier prefix: #{str}"
    end

    Ipv4Pool.new(
      ipv4_config: config,
      ipv4_first_address: first,
      ipv4_last_address: last)
  end
end
