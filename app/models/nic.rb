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

  def mac_address
    @mac_address ||= mac_address_data.presence&.unpack('H2' * 6)&.join(':') || ''
  end

  def mac_address=(value)
    @mac_address = value
    self.mac_address_data = @mac_address.presence && [@mac_address.delete('-:')].pack('H12')
  end

  def duid
    @duid ||= duid_data.presence&.unpack('H2' * duid_data.size)&.join('-') || ''
  end

  def duid=(value)
    @duid = value
    self.duid_data = @duid.presence && [@duid.delete('-:')].pack('H*')
  end

  # readonly
  def ipv4
    @ipv4 ||= ipv4_data.presence &&
            IPAddress::IPv4.parse_data(ipv4_data)
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
             IPAddress::IPv6.parse_data(ipv6_data)
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

  def set_ipv4!
    case ipv4_config
    when 'disabled'
      self.ipv4_address = nil
    when 'static'
      # if id
      #   old_nic = Nic.find(id).ipv4_address
      # end
      network.pools.where(ipv4_config: 'satic')
    when 'dynamic'
      network.pools.where(ipv4_config: 'dynamic')
    when 'reserved'
      network.pools.where(ipv4_config: 'reserved')
    when 'link_local'
      unless ipv4_address &&
        IPAddr.new('127.0.0.0/8').include?(IPAddr.new(ipv4_address))
        self.ipv4_address = '127.0.0.1'
      end
    else
      raise 'Invalid IP Config'
    end

    ipv4_normalize!
  end

  def set_ipv6!
  end
end
