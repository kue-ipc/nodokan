class Nic < ApplicationRecord
  include IpConfig
  include Ip6Config

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
  validates :ip_address, allow_blank: true, ip: true
  validates :ip6_address, allow_blank: true, ip6: true

  normalize_attribute :name
  normalize_attribute :mac_address
  normalize_attribute :duid
  normalize_attribute :ip_address
  normalize_attribute :ip6_address

  def mac_address
    @mac_address ||=
      mac_address_data.presence&.unpack('H2' * 6)&.join(':') || ''
  end

  def mac_address=(value)
    @mac_address = value
    self.mac_address_data = @mac_address.presence &&
                            MacAddress.new(@mac_address).data
  rescue ArgumentError
    self.mac_address_data = nil
  end

  def duid
    @duid ||=
      duid_data.presence&.unpack('H2' * duid_data.size)&.join('-') || ''
  end

  def duid=(value)
    @duid = value
    self.duid_data = @duid.presence && @duid.delete('-:').pack('H*')
  rescue ArgumentError
    self.duid_data = nil
  end

  # readonly
  def ip
    @ip ||= ip_data.presence &&
            IPAddress::IPv4.parse_data(ip_data)
  end

  def ip_address
    @ip_address ||= (ip&.address || '')
  end

  def ip_address=(value)
    @ip_address = value
    self.ip_data = @ip_address.presence &&
                   IPAddress::IPv4.new(@ip_address).data
  rescue ArgumentError
    self.ip_data = nil
  end

  # readonly
  def ip6
    @ip6 ||= ip6_data.presence &&
             IPAddress::IPv6.parse_data(ip6_data)
  end

  def ip6_address
    @ip6_address ||= (ip6&.address || '')
  end

  def ip6_address=(value)
    @ip6_address = value
    self.ip6_data = @ip6_address.presence &&
                    IPAddress::IPv6.new(@ip6_address).data
  rescue ArgumentError
    self.ip6_data = nil
  end

  def old_nic
    @old_nic ||= id && Nic.find(id)
  end

  def set_ip!
    case ip_config
    when 'disabled'
      self.ip_address = nil
    when 'static'
      # if id
      #   old_nic = Nic.find(id).ip_address
      # end
      network.pools.where(ip_config: 'satic')
    when 'dynamic'
      network.pools.where(ip_config: 'dynamic')
    when 'reserved'
      network.pools.where(ip_config: 'reserved')
    when 'link_local'
      unless ip_address &&
        IPAddr.new('127.0.0.0/8').include?(IPAddr.new(ip_address))
        self.ip_address = '127.0.0.1'
      end
    else
      raise 'Invalid IP Config'
    end

    ip_normalize!
  end

  def set_ip6!
  end
end
