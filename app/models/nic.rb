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
  belongs_to :network, counter_cache: true

  enum interface_type: {
    wired: 0,
    wireless: 1,
    bluetooth: 2,
    dialup: 4,
    vpn: 5,
    virtual: 8,
    nat: 16,
    shared: 17,
    reserved: 18,
    other: 127,
    unknown: -1,
  }

  validates :number,
    numericality: {only_integer: true, greater_than: 0, less_than_or_equal_to: 64},
    uniqueness: {scope: :node}
  validates :name, allow_blank: true, length: {maximum: 255}

  validates :ipv4_data, allow_nil: true, uniqueness: true
  validates :ipv6_data, allow_nil: true, uniqueness: true
  validates :mac_address_data, allow_nil: true, length: {is: 6}, uniqueness: true

  normalizes :name, with: ->(str) { str.presence&.strip }

  after_validation :replace_errors
  before_update :old_nic
  after_commit :radius_mac, :kea_reservation

  attr_accessor :skip_after_job

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

  def global?
    (ipv4_data.present? && !ipv4.private?) ||
      (ipv6_data.present? && !ipv6.private?)
  end
  alias global global?

  def old_nic
    if persisted?
      @old_nic ||= Nic.find(id)
    else
      @old_nic
    end
  end

  def same_old_nic?(*list)
    return false if old_nic.nil?

    list.all? do |name|
      __send__(name) == old_nic.__send__(name)
    end
  end

  def set_ipv4!(manageable = false)
    if network.nil?
      self.ipv4_address = nil
      return true
    end

    unless network.ipv4_configs.include?(ipv4_config)
      errors.add(:ipv4_config, t("errors.messages.invalid_config"))
      return false
    end

    case ipv4_config
    when "dynamic", "disabled"
      self.ipv4_address = nil
    when "reserved", "static"
      if manageable && ipv4_address.present?
        # nothing
      elsif same_old_nic?(:network_id, :ipv4_config)
        self.ipv4_address = old_nic.ipv4_address
      else
        unless (ipv4 = network.next_ipv4(ipv4_config))
          errors.add(:ipv4_config, t("errors.messages.no_free",
            name: t("messages.address_for_config", config: t(ipv4_config, scope: "activerecord.enums.ipv4_configs"))))
          return false
        end

        self.ipv4_address = ipv4.to_s
      end
    when "manual"
      if manageable
        if ipv4_address.blank?
          errors(:ipv4_address, t("errors.messages.blank"))
          return false
        end
      elsif same_old_nic?(:network_id, :ipv4_config)
        self.ipv4_address = old_nic.ipv4_address
      else
        errors(:ipv4_config, t("errors.messages.invalid_config"))
        return false
      end
    else
      errors(:ipv4_config, t("errors.messages.invalid_config"))
      return false
    end

    true
  end

  def set_ipv6!(manageable = false)
    if network.nil?
      self.ipv6_address = nil
      return true
    end

    unless network.ipv6_configs.include?(ipv6_config)
      errors(:ipv6_config, t("errors.messages.invalid_config"))
      return false
    end

    case ipv6_config
    when "dynamic", "disabled"
      self.ipv6_address = nil
    when "reserved", "static"
      if manageable && ipv6_address.present?
        # nothing
      elsif same_old_nic?(:network_id, :ipv6_config)
        self.ipv6_address = old_nic.ipv6_address
      else
        unless (ipv6 = network.next_ipv6(ipv6_config))
          errors.add(:ipv6_config, t("errors.messages.no_free",
            name: t("messages.address_for_config", config: t(ipv6_config, scope: "activerecord.enums.ipv4_configs"))))
          return false
        end

        self.ipv6_address = ipv6.to_s
      end
    when "manual"
      if manageable
        if ipv6_address.blank?
          errors(:ipv6_address, t("errors.messages.blank"))
          return false
        end
      elsif same_old_nic?(:network_id, :ipv6_config)
        self.ipv6_address = old_nic.ipv6_address
      else
        errors(:ipv6_config, t("errors.messages.invalid_config"))
        return false
      end
    else
      errors(:ipv6_config, t("errors.messages.invalid_config"))
      return false
    end

    true
  end

  def radius_mac
    return if skip_after_job

    if mac_address_data.present?
      if !destroyed? && auth
        RadiusMacAddJob.perform_later(mac_address_raw, network.vlan)
      else
        RadiusMacDelJob.perform_later(mac_address_raw)
      end
    end

    if old_nic&.mac_address_data.present? && old_nic.mac_address_data != mac_address_data
      RadiusMacDelJob.perform_later(old_nic.mac_address_raw)
    end
  end

  def kea_reservation
    return if skip_after_job

    if mac_address_data.present?
      if !destroyed? && ipv4_reserved? && ipv4_data.present? && network&.dhcp
        KeaReservation4AddJob.perform_later(mac_address_data, ipv4.to_i, network.id)
      else
        KeaReservation4DelJob.perform_later(mac_address_data)
      end
    end

    if old_nic&.mac_address_data.present? && old_nic.mac_address_data != mac_address_data
      KeaReservation4DelJob.perform_later(old_nic.mac_address_data)
    end

    if node.duid_data.present?
      if !destroyed? && ipv6_reserved? && ipv6_data.present? && network&.dhcp
        KeaReservation6AddJob.perform_later(node.duid_data, ipv6_address, network.id)
      else
        # FIXME: 複数のNIC登録の場合、同じDUIDがあるので、削除できない？
        # KeaReservation6DelJob.perform_later(node.duid_data)
      end
    end

    # FIXME: old_nicにはduid_dataはない？
    # if old_nic&.duid_data.present? && old_nic.duid_data != duid_data
    #   KeaReservation6DelJob.perform_later(old_nic.duid_data)
    # end
  end

  def flag
    FLAGS.map { |attr, c| self[attr].presence && c }.compact.join.presence
  end

  def flag=(str)
    FLAGS.each { |attr, c| self[attr] = true & str&.include?(c) }
  end

  def last_radpostauths
    @last_radpostauths ||= mac_address_data && Radius::Radpostauth
      .where(username: mac_address_raw, reply: "Access-Accept")
      .order(:authdate).last
  end

  def lease4
    @lease4 ||= mac_address_data && Kea::Lease4.find(hwaddr: mac_address_data)
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
end
