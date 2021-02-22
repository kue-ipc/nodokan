class Network < ApplicationRecord
  IP_MASKS = (0..32).map do |i|
    IPAddress::Prefix32.new(i).to_ip
  end

  has_many :nics, dependent: :nullify
  has_many :nodes, through: :nics

  has_many :ip_pools, dependent: :destroy
  accepts_nested_attributes_for :ip_pools, allow_destroy: true
  has_many :ip6_pools, dependent: :destroy
  accepts_nested_attributes_for :ip6_pools, allow_destroy: true

  has_many :auth_users, class_name: 'User', foreign_key: 'auth_network_id', dependent: :nullify
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true
  validates :vlan, allow_nil: true,
                   numericality: {
                     only_integer: true,
                     greater_than_or_equal_to: 1,
                     less_than_or_equal_to: 4094,
                   }

  validates :ip_network_address, allow_blank: true, ip: true
  validates :ip_gateway_address, allow_blank: true, ip: true
  validates :ip6_network_address, allow_blank: true, ip6: true
  validates :ip6_gateway_address, allow_blank: true, ip6: true

  validates :ip_netmask, allow_blank: true, inclusion: {in: IP_MASKS}

  validates :ip_prefixlen, allow_blank: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 32,
  }

  validates :ip6_prefixlen, allow_blank: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 128,
  }

  # before_save :ip_normalize!, :ip6_normalize!

  # IPv4

  # readonly
  def ip_network
    @ip_network ||= ip_network_data.presence &&
                    IPAddress::IPv4.parse_data(ip_network_data, ip_prefixlen)
  end

  def ip_network_address
    @ip_network_address ||= (ip_network&.address || '')
  end

  def ip_network_address=(value)
    @ip_network_address = value
    self.ip_network_data = @ip_network_address.presence &&
                           IPAddress::IPv4.new(@ip_network_address).data
  rescue ArgumentError
    self.ip_network_data = nil
  end

  def ip_netmask
    @ip_netmask ||= (ip_network&.netmask || '')
  end

  def ip_netmask=(value)
    @ip_netmask = value
    self.ip_prefixlen = @ip_netmask.presence &&
                        IPAddress::Prefix32.parse_netmask(@ip_netmask).to_i
  rescue ArgumentError
    self.ip_prefixlen = nil
  end

  # readonly
  def ip_gateway
    @ip_gateway ||= ip_gateway_data.presence &&
                    IPAddress::IPv4.parse_data(ip_gateway_data, ip_prefixlen)
  end

  def ip_gateway_address
    @ip_gateway_address ||= (ip_gateway&.address || '')
  end

  def ip_gateway_address=(value)
    @ip_gateway_address = value
    self.ip_gateway_data = @ip_gateway_address.presence &&
                           IPAddress::IPv4.new(@ip_gateway_address).data
  rescue ArgumentError
    self.ip_gateway_data = nil
  end

  # Ipv6

  # readonly
  def ip6_network
    @ip6_network ||= ip6_network_data.presence &&
                     IPAddress::IPv6.parse_data(ip6_network_data, ip6_prefixlen)
  end

  def ip6_network_address
    @ip6_network_address ||= (ip6_network&.address || '')
  end

  def ip6_network_address=(value)
    @ip6_network_address = value
    self.ip6_network_data = @ip6_network_address.presence &&
                            IPAddress::IPv6.new(@ip6_network_address).data
  rescue
    self.ip6_network_data = nil
  end

  # readonly
  def ip6_gateway
    @ip6_gateway ||= ip6_gateway_data.presence &&
                     IPAddress::IPv6.parse_data(ip6_gateway_data, ip6_prefixlen)
  end

  def ip6_gateway_address
    @ip6_gateway_address ||= (ip6_gateway&.address || '')
  end

  def ip6_gateway_address=(value)
    @ip6_gateway_address = value
    self.ip6_gateway_data = @ip6_gateway_address.presence &&
                            IPAddress::IPv6.new(@ip6_address).data
  rescue ArgumentError
    self.ip6_gateway_data = nil
  end

  # other
  def name_vlan
    if vlan.present?
      "#{name} (VLAN #{vlan})"
    else
      name
    end
  end

  # 空いている次のIPアドレス
  def next_ip(ip_config)
    return unless ip_network

    selected_ip_pools = ip_pools.where(ip_config: ip_config).order(:ip_first_data)
    return if selected_ip_pools.empty?

    nics_ips = nics.map(:ip).compact

    selected_ip_pools.each do |ip_pool|
      ip_pool.each do |ip|
        return ip if ip != ip_gateway && nics_ips.exclude?(ip)
      end
    end

    nil
  end

  def next_ip6(ip6_config)
    return unless ip6_network

    selected_ip6_pools = ip6_pools.where(ip6_config: ip6_config).order(:ip6_first_data)
    return if selected_ip6_pools.empty?

    nics_ip6s = nics.map(:ip6).compact

    selected_ip6_pools.each do |ip6_pool|
      ip6_pool.each do |ip6|
        return ip6 if ip6 != ip6_gateway && nics_ip6s.exclude?(ip6)
      end
    end

    nil
  end

  # 空いている次のプールのIPアドレス
  def next_ip_pool
    return unless ip_network

    (ip_network.first..ip_network.last).find do |ip|
      next if ip == ip_gateway

      ip_pools.all? do |ip_pool|
        ip_pool.exclude?(ip)
      end
    end
  end

  def next_ip6_pool
    return unless ip6_network

    (ip6_network.first..ip_network.last).find do |ip6|
      next if ip6 == ip6_gateway

      ip6_pools.all? do |ip6_pool|
        ip6_pool.exclude?(ip6)
      end
    end
  end
end
