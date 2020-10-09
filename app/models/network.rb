class Network < ApplicationRecord
  has_many :nics, dependent: :nullify

  has_many :ip_pools, dependent: :destroy
  has_many :ip6_pools, dependent: :destroy

  has_many :network_users, dependent: :destroy
  has_many :users, through: :network_users

  validates :name, presence: true
  validates :vlan, allow_nil: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: 4094,
    }

  before_save :ip_normalize, :ip6_normalize

  def ip_network
    @ip_network ||= ip_address.present? && "#{ip_address}/#{ip_mask}"
  end

  def ip6_network
    @ip6_network ||= ip6_address.present? && "#{ip6_address}/#{ip6_prefix}"
  end

  def ip_normalize
    if ip_network
      ip_network_addr = IPAddress::IPv4.new(ip_network)

      if ip_network_addr.network?
        errors.add(:ip_address, 'ネットワークアドレスではありません。')
      end

      ip_gateway_addr = IPAddress::IPv4.new(ip_gateway)
      unless ip_network_addr.include?(ip_gateway_addr)
        errors.add(:ip_gateway, 'ネットワークの範囲外です。')
      end

      self.ip_address = ip_network_addr.octets.map(&:to_s).join('.')
      self.ip_mask = ip_network_addr.netmask
      self.ip_gateway = ip_gateway_addr.octets.map(&:to_s).join('.')
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

      ip6_gateway_addr = IPAddress::IPv4.new(ip6_gateway)
      unless ip6_network_addr.include?(ip6_gateway_addr)
        errors.add(:ip6_gateway, 'ネットワークの範囲外です。')
        return false
      end

      self.ip6_address = ip6_network_addr.address
      self.ip6_prefix = ip6_network_addr.prefix
      self.ip6_gateway = ip6_gateway_addr.address
    else
      self.ip6_address = nil
      self.ip6_prefix = nil
      self.ip6_gateway = nil
    end
    true
  end

end
