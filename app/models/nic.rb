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
  validates :mac_address, allow_nil: true, format: {
    with: /\A\h{2}(?:[-:.]?\h{2}){5}\z/,
    message: 'MACアドレスの形式ではありません。' \
      '通常は「hh:hh:hh:hh:hh:hh」または「HH-HH-HH-HH-HH-HH」です。',
  }
  validates :duid, allow_nil: true, format: {
    with: /\A\h{2}(?:[-:]h{2})*\z/,
    message: 'DUIDの形式ではありません。' \
      '「-」または「:」区切りの二桁ごとの16進数でなければなりません。',
  }
  validates :ip_address, allow_nil: true, ip: true
  validates :ip6_address, allow_nil: true, ip6: true

  normalize_attribute :name
  normalize_attribute :mac_address
  normalize_attribute :duid
  normalize_attribute :ip_address
  normalize_attribute :ip6_address

  before_save :mac_normalize!, if: proc { mac_address.present? }
  before_save :duid_normalize!, if: proc { duid.present? }
  before_save :ip_normalize!, if: proc { ip_address.present? }
  before_save :ip6_normalize!, if: proc { ip6_address.present? }

  def mac_normalize!
    self.mac_address = MacAddress.new(mac_address)
      .to_s.each_char.each_slice(2).map(&:join).join(':')
    true
  end

  def duid_normalize!
    self.duid = duid.upcase.gsub(':', '-')
    true
  end

  def ip_normalize!
    self.ip_address = IPAddr.new(ip_address).to_s
    true
  end

  def ip6_normalize!
    self.ip6_address = IPAddr.new(ip6_address).to_s
    true
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
