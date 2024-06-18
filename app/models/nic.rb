# rubocop: disable Metrics

class Nic < ApplicationRecord
  include Ipv4Config
  include Ipv6Config
  include Ipv4Data
  include Ipv6Data
  include MacAddressData

  FLAGS = {
    auth: "a",
    locked: "l",
  }.freeze

  belongs_to :node, counter_cache: true
  belongs_to :network, counter_cache: true, optional: true

  enum interface_type: {
    wired: 0,
    wireless: 1,
    virtual: 8,
    vpn: 9,
    nat: 16,
    shared: 17,
    reserved: 18,
    other: 127,
    unknown: -1,
  }

  validates :number, uniqueness: {scope: :node}, numericality: {
    only_integer: true, greater_than: 0, less_than_or_equal_to: 64,
  }

  validates :name, allow_blank: true, length: {maximum: 255}
  validates :interface_type, presence: true

  validates :ipv4_data, allow_nil: true, uniqueness: true
  validates :ipv4_data, presence: true,
    if: -> { ipv4_reserved? || ipv4_static? || ipv4_manual? }
  validates :ipv6_data, allow_nil: true, uniqueness: true
  validates :ipv6_data, presence: true,
    if: -> { ipv6_reserved? || ipv6_static? || ipv6_manual? }

  validates :mac_address_data, allow_nil: true, length: {is: 6}
  validates :mac_address_data, presence: true, if: -> { auth }

  validates :ipv4_config, ip_config: true
  validates :ipv4_config, exclusion: ["reserved"],
    if: -> { mac_address_data.blank? }
  validates :ipv6_config, ip_config: true
  validates :ipv6_config, exclusion: ["reserved"],
    if: -> { node.duid_data.blank? }

  validates :network, presence: true,
    if: -> { Settings.config.nic_require_network }

  validates_with UniqueMacAddressValidator

  normalizes :name, with: ->(str) { str.presence&.strip }

  before_validation :auto_assign_ipv4, :auto_assign_ipv6
  after_validation :replace_errors
  before_save :clear_auth_without_network
  after_commit :radius_mac, :kea_reservation4, :kea_reservation6,
    unless: :skip_after_job?

  attr_accessor :skip_after_job

  def skip_after_job?
    skip_after_job.present?
  end

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w(
      node_id network_id
      number name interface_type
      auth locked
      mac_address_data
      ipv4_config ipv4_data
      ipv6_config ipv6_data
      ipv4_resolved_at ipv6_discovered_at ipv4_leased_at ipv6_leased_at auth_at
    )
  end

  def self.ransackable_associations(auth_object = nil)
    ["network", "node"]
  end
  # rubocop: enable Lint/UnusedMethodArgument

  attribute :global, :boolean
  def global
    (ipv4_data.present? && !ipv4.private?) ||
      (ipv6_data.present? && !ipv6.private?)
  end
  alias global? global

  def radius_mac
    return if network.nil?

    if mac_address_data.present?
      if !destroyed? && auth
        RadiusMacAddJob.perform_later(mac_address_raw, network.vlan)
      else
        RadiusMacDelJob.perform_later(mac_address_raw)
      end
    end
  end

  def kea_reservation4
    return if network.nil?
    return if mac_address_data.blank?

    if !destroyed? && has_ipv4? && ipv4_reserved? && network.dhcpv4?
      KeaReservation4AddJob.perform_later(network.id, mac_address_data, ipv4)
    else
      KeaReservation4DelJob.perform_later(network.id, mac_address_data)
    end
  end

  def kea_reservation6
    return if network.nil?
    return if node.duid_data.blank?

    if !destroyed? && has_ipv6? && ipv6_reserved? && network.dhcpv6?
      KeaReservation6AddJob.perform_later(network.id, node.duid_data, ipv6)
    else
      KeaReservation6DelJob.perform_later(network.id, node.duid_data)
    end
  end

  def flag
    FLAGS.map { |attr, c| self[attr].presence && c }.compact.join.presence
  end

  def flag=(str)
    FLAGS.each { |attr, c| self[attr] = true & str&.include?(c) }
  end

  private def auto_assign_ipv4
    if network.nil?
      self.ipv4 = nil
      return
    end

    case ipv4_config
    when "dynamic", "disabled"
      self.ipv4 = nil
    when "reserved", "static"
      unless has_ipv4?
        next_ip = network.next_ipv4(ipv4_config)
        if next_ip.nil?
          errors.add(:ipv4_config, :no_free)
          throw :abort
        end
        self.ipv4 = next_ip
      end
    end
  end

  private def auto_assign_ipv6
    if network.nil?
      self.ipv6 = nil
      return
    end

    case ipv6_config
    when "dynamic", "disabled"
      self.ipv6 = nil
    when "reserved", "static"
      unless has_ipv6?
        next_ip = network.next_ipv6(ipv6_config)
        if next_ip.nil?
          errors.add(:ipv6_config, :no_free)
          throw :abort
        end
        self.ipv6 = next_ip
      end
    when "mapped"
      if ["static", "manual"].exclude?(ipv4_config)
        errors.add(:ipv6_config, :not_static_ipv4)
        throw :abort
      end
      mapped_ip = network.mapped_ipv6(ipv4)
      if mapped_ip.nil?
        errors.add(:ipv6_config, :no_mapped_pool)
        throw :abort
      end
      self.ipv6 = mapped_ip
    end
  end

  private def hex_str(list, char_case: :lower, sep: nil)
    hex = case char_case.intern
          when :upper
            "%02X"
          when :lower
            "%02x"
          else
            raise ArgumentError, "invalid char_case: #{char_case}"
    end
    format_str = [[hex] * list.size].join(sep || "")
    format_str % list
  end

  private def replace_errors
    errors[:mac_address_data].each do |msg|
      errors.add(:mac_address, msg)
    end
    errors[:ipv4_data].each do |msg|
      errors.add(:ipv4_address, msg)
    end
    errors[:ipv6_data].each do |msg|
      errors.add(:ipv6_address, msg)
    end
  end

  private def clear_auth_without_network
    return if network&.auth

    self.auth = false
  end
end
