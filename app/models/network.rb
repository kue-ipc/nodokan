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

  has_many :auth_users, class_name: 'User', foreign_key: 'auth_network_id',
                        dependent: :nullify
  has_and_belongs_to_many :users

  validates :name, presence: true, uniqueness: true
  validates :vlan, allow_nil: true, uniqueness: true,
                   numericality: {
                     only_integer: true,
                     greater_than_or_equal_to: 1,
                     less_than_or_equal_to: 4094,
                   }

  validates :ipv4_network_address, allow_blank: true, ipv4: true
  validates :ipv4_gateway_address, allow_blank: true, ipv4: true
  validates :ipv6_network_address, allow_blank: true, ipv6: true
  validates :ipv6_gateway_address, allow_blank: true, ipv6: true

  validates :ipv4_netmask, allow_blank: true, inclusion: {in: IP_MASKS}

  validates :ipv4_prefix_length, allow_blank: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 32,
  }

  validates :ipv6_prefix_length, allow_blank: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 128,
  }

  # IPv4

  # readonly
  def ipv4_network
    @ipv4_network ||=
      ipv4_network_data.presence &&
      IPAddress::IPv4.parse_data(ipv4_network_data, ipv4_prefix_length)
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
    self.ipv4_prefix_length =
      @ipv4_netmask.presence &&
      IPAddress::Prefix32.parse_netmask(@ipv4_netmask).to_i
  rescue ArgumentError
    self.ipv4_prefix_length = nil
  end

  # readonly
  def ipv4_gateway
    @ipv4_gateway ||=
      ipv4_gateway_data.presence &&
      IPAddress::IPv4.parse_data(ipv4_gateway_data, ipv4_prefix_length)
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
    @ipv6_network ||=
      ipv6_network_data.presence &&
      IPAddress::IPv6.parse_data(ipv6_network_data).tap do |ipv6|
        ipv6.prefix = ipv6_prefix_length
      end
  end

  def ipv6_network_address
    @ipv6_network_address ||= (ipv6_network&.address || '')
  end

  def ipv6_network_address=(value)
    @ipv6_network_address = value
    self.ipv6_network_data = @ipv6_network_address.presence &&
                             IPAddress::IPv6.new(@ipv6_network_address).data
  rescue ArgumentError
    self.ipv6_network_data = nil
  end

  # readonly
  def ipv6_gateway
    @ipv6_gateway ||=
      ipv6_gateway_data.presence &&
      IPAddress::IPv6.parse_data(ipv6_gateway_data, ipv6_prefix_length)
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
  def next_ipv4(ipv4_config)
    return unless ipv4_network

    selected_ip_pools = ipv4_pools
      .where(ipv4_config: ipv4_config).order(:ipv4_first_data)
    return if selected_ip_pools.empty?

    nics_ipv4s = nics.map(&:ipv4).compact

    selected_ip_pools.each do |ipv4_pool|
      ipv4_pool.each do |ipv4|
        return ipv4 if ipv4 != ipv4_gateway && nics_ipv4s.exclude?(ipv4)
      end
    end

    nil
  end

  def next_ipv6(ipv6_config)
    return unless ipv6_network

    selected_ipv6_pools = ipv6_pools
      .where(ipv6_config: ipv6_config).order(:ipv6_first_data)
    return if selected_ipv6_pools.empty?

    nics_ipv6s = nics.map(:ipv6).compact

    selected_ipv6_pools.each do |ipv6_pool|
      ipv6_pool.each do |ipv6|
        return ipv6 if ipv6 != ipv6_gateway && nics_ipv6s.exclude?(ipv6)
      end
    end

    nil
  end

  # 空いている次のプールのIPアドレス
  def next_ipv4_pool
    return unless ipv4_network

    (ipv4_network.first..ipv4_network.last).find do |ipv4|
      next if ipv4 == ipv4_gateway

      ipv4_pools.all? do |ipv4_pool|
        ipv4_pool.exclude?(ipv4)
      end
    end
  end

  def next_ipv6_pool
    return unless ipv6_network

    (ipv6_network.first..ipv4_network.last).find do |ipv6|
      next if ipv6 == ipv6_gateway

      ipv6_pools.all? do |ipv6_pool|
        ipv6_pool.exclude?(ipv6)
      end
    end
  end

  def ipv4_configs
    @ipv4_configs ||=
      ipv4_pools.map(&:ipv4_config).then do |list|
        (list + ['manual', 'disabled']).uniq
      end
  end

  def ipv6_configs
    @ipv6_configs ||=
      ipv6_pools.map(&:ipv6_config).then do |list|
        (list + ['manual', 'disabled']).uniq
      end
  end

  def self.next_free
    # 後で考える。
    Nework.where(auth: true).first
  end
end
