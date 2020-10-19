class Network < ApplicationRecord
  IP_MASKS = (0..32).map do |i|
    [(IPAddr::IN4MASK - (1<<i) + 1)].pack('N').unpack('C*')
      .map(&:to_s).join('.')
  end.reverse

  has_many :nics, dependent: :nullify

  has_many :ip_pools, dependent: :destroy
  accepts_nested_attributes_for :ip_pools, allow_destroy: true
  has_many :ip6_pools, dependent: :destroy
  accepts_nested_attributes_for :ip6_pools, allow_destroy: true


  has_many :network_users, dependent: :destroy
  has_many :users, through: :network_users

  validates :name, presence: true, uniqueness: true
  validates :vlan, allow_nil: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 4094,
    }

  validates :ip_address, allow_blank: true, ip: true
  validates :ip_gateway, allow_blank: true, ip: true
  validates :ip6_address, allow_blank: true, ip6: true
  validates :ip6_gateway, allow_blank: true, ip6: true

  validates :ip_mask, allow_blank: true,
    inclusion: {
      in: (0..32).map do |i|
        [(IPAddr::IN4MASK - (1<<i) + 1)].pack('N').unpack('C*')
          .map(&:to_s).join('.')
      end + (0..32).map(&:to_s)
    }
  validates :ip6_prefix, allow_blank: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 128,
  }

  before_save :ip_normalize, :ip6_normalize

  def ip_network
    return nil if ip_address.blank?

    @ip_network ||= "#{ip_address}/#{ip_mask}"
  end

  def ip6_network
    return nil if ip6_address.blank?

    @ip6_network ||= "#{ip6_address}/#{ip6_prefix}"
  end

  def ip_normalize
    if ip_network
      ip_network_addr = IPAddress::IPv4.new(ip_network)

      if ip_network_addr.network?
        errors.add(:ip_address, 'ネットワークアドレスではありません。')
      end

      self.ip_address = ip_network_addr.octets.map(&:to_s).join('.')
      self.ip_mask = ip_network_addr.netmask

      if ip_gateway.present?
        ip_gateway_addr = IPAddress::IPv4.new(ip_gateway)
        unless ip_network_addr.include?(ip_gateway_addr)
          errors.add(:ip_gateway, 'ネットワークの範囲外です。')
        end
        self.ip_gateway = ip_gateway_addr&.octets.map(&:to_s).join('.')
      else
        self.ip_gateway = nil
      end
    else
      self.ip_address = nil
      self.ip_mask = nil
      self.ip_gateway = nil
    end
    true
  end

  def ip6_normalize
    if ip6_network
      ip6_network_addr = IPAddress::IPv6.new(ip6_network)

      if ip6_network_addr.network?
        errors.add(:ip6_address, 'ネットワークアドレスではありません。')
        return false
      end

      self.ip6_address = ip6_network_addr.address
      self.ip6_prefix = ip6_network_addr.prefix

      if ip6_gateway.present?
        ip6_gateway_addr = IPAddress::IPv4.new(ip6_gateway)
        unless ip6_network_addr.include?(ip6_gateway_addr)
          errors.add(:ip6_gateway, 'ネットワークの範囲外です。')
          return false
        end
        self.ip6_gateway = ip6_gateway_addr.address
      else
        self.ip6_gateway = nil
      end
    else
      self.ip6_address = nil
      self.ip6_prefix = nil
      self.ip6_gateway = nil
    end
    true
  end

end
