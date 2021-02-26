class Network < ApplicationRecord
  IP_MASKS = (0..32).map do |i|
    IPAddress::Prefix32.new(i).to_ip
  end

  has_many :nics, dependent: :nullify
  has_many :nodes, through: :nics

  has_many :ipv4_pools, dependent: :destroy
  accepts_nested_attributes_for :ipv4_pools, allow_destroy: true
  has_many :ipv6_pools, dependent: :destroy
  accepts_nested_attributes_for :ipv6_pools, allow_destroy: true

  has_many :auth_users, class_name: 'User', foreign_key: 'auth_network_id', dependent: :nullify
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true
  validates :vlan, allow_nil: true,
                   numericality: {
                     only_integer: true,
                     greater_than_or_equal_to: 1,
                     less_than_or_equal_to: 4094,
                   }

  validates :ipv4_network_address, allow_blank: true, ip: true
  validates :ipv4_gateway_address, allow_blank: true, ip: true
  validates :ipv6_network_address, allow_blank: true, ip6: true
  validates :ipv6_gateway_address, allow_blank: true, ip6: true

  validates :ipv4_netmask, allow_blank: true, inclusion: {in: IP_MASKS}

  validates :ipv4_prefixlen, allow_blank: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 32,
  }

  validates :ipv6_prefixlen, allow_blank: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 128,
  }

  # before_save :ipv4_normalize!, :ipv6_normalize!

  # IPv4

  # readonly
  def ipv4_network
    @ipv4_network ||= ipv4_network_data.presence &&
                    IPAddress::IPv4.parse_data(ipv4_network_data, ipv4_prefixlen)
  end

  def ipv4_network_address
    @ipv4_network_address ||= (ipv4_network&.address || '')
  end

  def ipv4_network_address=(value)
    @ipv4_network_address = value
    self.ipv4_network_data = @ipv4_network_address.presence &&
                           IPAddress::IPv4.new(@ipv4_network_address).data
  rescue ArgumentError
    self.ipv4_network_data = nil
  end

  def ipv4_netmask
    @ipv4_netmask ||= (ipv4_network&.netmask || '')
  end

  def ipv4_netmask=(value)
    @ipv4_netmask = value
    self.ipv4_prefixlen = @ipv4_netmask.presence &&
                        IPAddress::Prefix32.parse_netmask(@ipv4_netmask).to_i
  rescue ArgumentError
    self.ipv4_prefixlen = nil
  end

  # readonly
  def ipv4_gateway
    @ipv4_gateway ||= ipv4_gateway_data.presence &&
                    IPAddress::IPv4.parse_data(ipv4_gateway_data, ipv4_prefixlen)
  end

  def ipv4_gateway_address
    @ipv4_gateway_address ||= (ipv4_gateway&.address || '')
  end

  def ipv4_gateway_address=(value)
    @ipv4_gateway_address = value
    self.ipv4_gateway_data = @ipv4_gateway_address.presence &&
                           IPAddress::IPv4.new(@ipv4_gateway_address).data
  rescue ArgumentError
    self.ipv4_gateway_data = nil
  end

  # Ipv6

  # readonly
  def ipv6_network
    @ipv6_network ||= ipv6_network_data.presence &&
                     IPAddress::IPv6.parse_data(ipv6_network_data, ipv6_prefixlen)
  end

  def ipv6_network_address
    @ipv6_network_address ||= (ipv6_network&.address || '')
  end

  def ipv6_network_address=(value)
    @ipv6_network_address = value
    self.ipv6_network_data = @ipv6_network_address.presence &&
                            IPAddress::IPv6.new(@ipv6_network_address).data
  rescue
    self.ipv6_network_data = nil
  end

  # readonly
  def ipv6_gateway
    @ipv6_gateway ||= ipv6_gateway_data.presence &&
                     IPAddress::IPv6.parse_data(ipv6_gateway_data, ipv6_prefixlen)
  end

  def ipv6_gateway_address
    @ipv6_gateway_address ||= (ipv6_gateway&.address || '')
  end

  def ipv6_gateway_address=(value)
    @ipv6_gateway_address = value
    self.ipv6_gateway_data = @ipv6_gateway_address.presence &&
                            IPAddress::IPv6.new(@ipv6_address).data
  rescue ArgumentError
    self.ipv6_gateway_data = nil
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
  def next_ip(ipv4_config)
    return unless ipv4_network

    selected_ip_pools = ipv4_pools.where(ipv4_config: ipv4_config).order(:ipv4_first_data)
    return if selected_ip_pools.empty?

    nics_ips = nics.map(:ip).compact

    selected_ip_pools.each do |ipv4_pool|
      ipv4_pool.each do |ip|
        return ip if ip != ipv4_gateway && nics_ips.exclude?(ip)
      end
    end

    nil
  end

  def next_ip6(ipv6_config)
    return unless ipv6_network

    selected_ip6_pools = ipv6_pools.where(ipv6_config: ipv6_config).order(:ipv6_first_data)
    return if selected_ip6_pools.empty?

    nics_ip6s = nics.map(:ip6).compact

    selected_ip6_pools.each do |ipv6_pool|
      ipv6_pool.each do |ip6|
        return ip6 if ip6 != ipv6_gateway && nics_ip6s.exclude?(ip6)
      end
    end

    nil
  end

  # 空いている次のプールのIPアドレス
  def next_ip_pool
    return unless ipv4_network

    (ipv4_network.first..ipv4_network.last).find do |ip|
      next if ip == ipv4_gateway

      ipv4_pools.all? do |ipv4_pool|
        ipv4_pool.exclude?(ip)
      end
    end
  end

  def next_ip6_pool
    return unless ipv6_network

    (ipv6_network.first..ipv4_network.last).find do |ip6|
      next if ip6 == ipv6_gateway

      ipv6_pools.all? do |ipv6_pool|
        ipv6_pool.exclude?(ip6)
      end
    end
  end
end
