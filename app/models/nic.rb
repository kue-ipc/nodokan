class Nic < ApplicationRecord
  include Ipv4Config
  include Ipv6Config

  belongs_to :node
  belongs_to :network, optional: true

  enum interface_type: {
    wired: 0,
    wireless: 1,
    virtual: 2,
    bluetooth: 3,
    dialup: 4,
    vpn: 5,
    other: 255,
    unknown: -1,
  }

  validates :name, length: {maximum: 255}
  validates :mac_address, allow_blank: true, format: {
    with: /\A\h{2}(?:[-:.]?\h{2}){5}\z/,
    message: 'MACアドレスの形式ではありません。' \
      '通常は「hh:hh:hh:hh:hh:hh」または「HH-HH-HH-HH-HH-HH」です。',
  }
  validates :duid, allow_blank: true, format: {
    with: /\A\h{2}(?:[-:]h{2})*\z/,
    message: 'DUIDの形式ではありません。' \
      '「-」または「:」区切りの二桁ごとの16進数でなければなりません。',
  }
  validates :ipv4_address, allow_blank: true, ipv4: true
  validates :ipv6_address, allow_blank: true, ipv6: true

  normalize_attribute :name
  normalize_attribute :mac_address
  normalize_attribute :duid
  normalize_attribute :ipv4_address
  normalize_attribute :ipv6_address

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
    mac_address(char_case :lower, sep: '')
  end

  def mac_address_win
    mac_address(char_case :upper, sep: '-')
  end

  def mac_address_colon
    mac_address(char_case :upper, sep: ':')
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
    duid(char_case :lower, sep: '')
  end

  def duid_win
    duid(char_case :upper, sep: '-')
  end

  def duid_colon
    duid(char_case :lower, sep: ':')
  end

  def duid_list
    @duid_list ||= duid_data.presence&.unpack('C2' * duid_data.size) || []
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
    @old_nic ||= id && Nic.find(id)
  end

  def same_old_nic?(*list)
    return false if old_nic.nil?

    list.all? do |name|
      __send__(name) == old_nic.__send__(name)
    end
  end

  def set_ipv4!
    if same_old_nic?(:network_id, :ipv4_config)
      self.ipv4_address = old_nic.ipv4_address
      return true
    end

    unless network.ipv4_configs.include?(ipv4_config)
      errors[:ipv4_config] << 'このネットワークに設定することはできません。'
      return false
    end

    case ipv4_config
    when 'dynamic', 'link_local', 'disabled'
      self.ipv4_address = ''
    when 'reserved'
      unless (ipv4 = network.next_ipv4('reserved'))
        errors[:ipv4_config] << '予約用アドレスの空きがありません。'
        return false
      end

      self.ipv4_address = ipv4.address
    when 'static'
      unless (ipv4 = network.next_ipv4('static'))
        errors[:ipv4_config] << '固定用アドレスの空きがありません。'
        return false
      end

      self.ipv4_address = ipv4.address
    when 'manual'
      # do nothing
    else
      errors[:ipv4_config] << '不正な設定です。'
      return false
    end

    true
  end

  def set_ipv6!
    if same_old_nic?(:network_id, :ipv6_config)
      self.ipv6_address = old_nic.ipv6_address
      return true
    end

    unless network.ipv6_configs.include?(ipv6_config)
      errors[:ipv6_config] << 'このネットワークに設定することはできません。'
      return false
    end

    case ipv6_config
    when 'dynamic', 'link_local', 'disabled'
      self.ipv6_address = ''
    when 'reserved'
      unless (ipv6 = network.next_ipv6('reserved'))
        errors[:ipv6_config] << '予約用アドレスの空きがありません。'
        return false
      end

      self.ipv6_address = ipv6.address
    when 'static'
      unless (ipv6 = network.next_ipv6('static'))
        errors[:ipv6_config] << '固定用アドレスの空きがありません。'
        return false
      end

      self.ipv6_address = ipv6.address
    when 'manual'
      # do nothing
    else
      errors[:ipv6_config] << '不正な設定です。'
      return false
    end

    true
  end

  private
    def hex_str(list, char_case: :lower, sep: nil)
      hex =
        case char_case
        when :upper
          '%2X'
        when :lower
          '%2x'
        else
          raise ArgumentError, "invalid char_case: #{char_case}"
        end
      format_str = [[hex] * list.size].join(sep || '')
      format_str % list
    end
end
