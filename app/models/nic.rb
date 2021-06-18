class Nic < ApplicationRecord
  include Ipv4Config
  include Ipv6Config

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
    share: 17,
    other: 127,
    unknown: -1,
  }

  validates :number,
    numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 64 },
    uniqueness: { scope: :node }
  validates :name, length: { maximum: 255 }
  validates :mac_address, allow_blank: true,
                          format: {
                            with: /\A\h{2}(?:[-:.]?\h{2}){5}\z/,
                            message: 'MACアドレスの形式ではありません。' \
                            '通常は「hh:hh:hh:hh:hh:hh」または「HH-HH-HH-HH-HH-HH」です。',
                          }
  validates :duid, allow_blank: true,
                   format: {
                     with: /\A\h{2}(?:[-:]h{2})*\z/,
                     message: 'DUIDの形式ではありません。' \
                     '「-」または「:」区切りの二桁ごとの16進数でなければなりません。',
                   }
  validates :ipv4_address, allow_blank: true, ipv4: true
  validates :ipv6_address, allow_blank: true, ipv6: true

  validates :ipv4_data, allow_nil: true, uniqueness: { case_sensitive: true }
  validates :ipv6_data, allow_nil: true, uniqueness: { case_sensitive: true }
  validates :mac_address_data, allow_nil: true, uniqueness: { case_sensitive: true }

  normalize_attribute :name
  normalize_attribute :mac_address
  normalize_attribute :duid
  normalize_attribute :ipv4_address
  normalize_attribute :ipv6_address

  after_validation :replace_errors
  before_update :old_nic
  after_commit :radius_mac, :kea_reservation

  def mac_address_gl
    @mac_address_gl ||= !((mac_address_list.first || 0) & 0x02).zero?
  end

  def mac_address_ig
    @mac_address_ig ||= !((mac_address_list.first || 0) & 0x01).zero?
  end

  def mac_address_global?
    !mac_address_gl
  end

  def mac_address_local?
    mac_address_gl
  end

  def mac_address_unicast?
    !mac_address_ig
  end

  def mac_address_multicast?
    mac_address_ig
  end

  def mac_address_list
    @mac_address_list ||= mac_address_data.presence&.unpack('C6') || []
  end

  def mac_address_raw
    mac_address(char_case: :lower, sep: '')
  end

  def mac_address_win
    mac_address(char_case: :upper, sep: '-')
  end

  def mac_address_colon
    mac_address(char_case: :upper, sep: ':')
  end

  def mac_address(char_case: Settings.config.mac_address_style.char_case,
                  sep: Settings.config.mac_address_style.sep)
    hex_str(mac_address_list, char_case: char_case, sep: sep)
  end

  def mac_address=(value)
    @mac_address = value
    self.mac_address_data =
      @mac_address.presence && [@mac_address.delete('-:')].pack('H12')
  end

  def duid_raw
    duid(char_case: :lower, sep: '')
  end

  def duid_win
    duid(char_case: :upper, sep: '-')
  end

  def duid_colon
    duid(char_case: :lower, sep: ':')
  end

  def duid_list
    @duid_list ||= duid_data.presence&.unpack('C*') || []
  end

  def duid(char_case: Settings.config.duid_style.char_case,
           sep: Settings.config.duid_style.sep)
    hex_str(duid_list, char_case: char_case, sep: sep)
  end

  def duid=(value)
    @duid = value
    self.duid_data = @duid.presence && [@duid.delete('-:')].pack('H*')
  end

  # readonly
  def ipv4
    @ipv4 ||= ipv4_data.presence &&
              IPAddress::IPv4.parse_data(ipv4_data, network.ipv4_prefix_length)
  end

  def ipv4_address
    @ipv4_address ||= (ipv4&.address || '')
  end

  def ipv4_address=(value)
    @ipv4_address = value
    self.ipv4_data = @ipv4_address.presence &&
                     IPAddress::IPv4.new(@ipv4_address).data
  rescue ArgumentError
    self.ipv4_data = nil
  end

  # readonly
  def ipv6
    @ipv6 ||= ipv6_data.presence &&
              IPAddress::IPv6.parse_data(ipv6_data, network.ipv6_prefix_length)
  end

  def ipv6_address
    @ipv6_address ||= (ipv6&.address || '')
  end

  def ipv6_address=(value)
    @ipv6_address = value
    self.ipv6_data = @ipv6_address.presence &&
                     IPAddress::IPv6.new(@ipv6_address).data
  rescue ArgumentError
    self.ipv6_data = nil
  end

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
      errors[:ipv4_config] << 'このネットワークに設定することはできません。'
      return false
    end

    case ipv4_config
    when 'dynamic', 'disabled'
      self.ipv4_address = nil
    when 'reserved'
      if manageable && ipv4_address.present?
        # nothing
      elsif same_old_nic?(:network_id, :ipv4_config)
        self.ipv4_address = old_nic.ipv4_address
      else
        unless (ipv4 = network.next_ipv4('reserved'))
          errors[:ipv4_config] << '予約用アドレスの空きがありません。'
          return false
        end

        self.ipv4_address = ipv4.address
      end
    when 'static'
      if manageable && ipv4_address.present?
        # nothing
      elsif same_old_nic?(:network_id, :ipv4_config)
        self.ipv4_address = old_nic.ipv4_address
      else
        unless (ipv4 = network.next_ipv4('static'))
          errors[:ipv4_config] << '固定用アドレスの空きがありません。'
          return false
        end

        self.ipv4_address = ipv4.address
      end
    when 'manual'
      if manageable
        unless ipv4_address.blank?
          errors[:ipv4_address] << '手動の場合はアドレスが必要です。'
          return false
        end
      elsif same_old_nic?(:network_id, :ipv4_config)
        self.ipv4_address = old_nic.ipv4_address
      else
        errors[:ipv4_config] << '管理者以外は手動に設定できません。'
        return false
      end
    else
      errors[:ipv4_config] << '不正な設定です。'
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
      errors[:ipv6_config] << 'このネットワークに設定することはできません。'
      return false
    end

    case ipv6_config
    when 'dynamic', 'disabled'
      self.ipv6_address = nil
    when 'reserved'
      if manageable && ipv6_address.present?
        # nothing
      elsif same_old_nic?(:network_id, :ipv6_config)
        self.ipv6_address = old_nic.ipv6_address
      else
        unless (ipv6 = network.next_ipv6('reserved'))
          errors[:ipv6_config] << '予約用アドレスの空きがありません。'
          return false
        end

        self.ipv6_address = ipv6.address
      end
    when 'static'
      if manageable && ipv6_address.present?
        # nothing
      elsif same_old_nic?(:network_id, :ipv6_config)
        self.ipv6_address = old_nic.ipv6_address
      else
        unless (ipv6 = network.next_ipv6('static'))
          errors[:ipv6_config] << '固定用アドレスの空きがありません。'
          return false
        end

        self.ipv6_address = ipv6.address
      end
    when 'manual'
      if manageable
        unless ipv6_address.blank?
          errors[:ipv6_address] << '手動の場合はアドレスが必要です。'
          return false
        end
      elsif same_old_nic?(:network_id, :ipv6_config)
        self.ipv6_address = old_nic.ipv6_address
      else
        errors[:ipv6_config] << '管理者以外は手動に設定できません。'
        return false
      end
    else
      errors[:ipv6_config] << '不正な設定です。'
      return false
    end

    true
  end

  def radius_mac
    if mac_address_data.present?
      if !destroyed? && auth
        RadiusMacAddJob.perform_later(mac_address_raw, network.vlan)
      else
        RadiusMacDelJob.perform_later(mac_address_raw)
      end
    end

    # rubocop:disable Style/GuardClause
    if old_nic&.mac_address_data.present? && old_nic.mac_address_data != mac_address_data
      RadiusMacDelJob.perform_later(old_nic.mac_address_raw)
    end
    # rubocop:enable Style/GuardClause
  end

  def kea_reservation
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

    if duid_data.present?
      if !destroyed? && ipv6_reserved? && ipv6_data.present? && network&.dhcp
        KeaReservation6AddJob.perform_later(duid_data, ipv6_address, network.id)
      else
        KeaReservation6DelJob.perform_later(duid_data)
      end
    end

    if old_nic&.duid_data.present? && old_nic.duid_data != duid_data
      KeaReservation6DelJob.perform_later(old_nic.duid_data)
    end
  end

  private def hex_str(list, char_case: :lower, sep: nil)
    hex = case char_case.intern
          when :upper
            '%02X'
          when :lower
            '%02x'
          else
            raise ArgumentError, "invalid char_case: #{char_case}"
          end
    format_str = [[hex] * list.size].join(sep || '')
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
