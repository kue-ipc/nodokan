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
                    IPAddress::IPv4.parse_data(ip_gateway_data)
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
                     IPAddress::IPv6.parse_data(ip6_gateway_data)
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


  # def ip_normalize!
  #   if ip_network
  #     ip_network_addr = IPAddress::IPv4.new(ip_network)

  #     errors.add(:ip_address, 'ネットワークアドレスではありません。') if ip_network_addr.network?

  #     self.ip_address = ip_network_addr.octets.map(&:to_s).join('.')
  #     self.ip_mask = ip_network_addr.netmask

  #     if ip_gateway.present?
  #       ip_gateway_addr = IPAddress::IPv4.new(ip_gateway)
  #       unless ip_network_addr.include?(ip_gateway_addr)
  #         errors.add(:ip_gateway, 'ネットワークの範囲外です。')
  #       end
  #       self.ip_gateway = ip_gateway_addr&.octets.map(&:to_s).join('.')
  #     else
  #       self.ip_gateway = nil
  #     end
  #   else
  #     self.ip_address = nil
  #     self.ip_mask = nil
  #     self.ip_gateway = nil
  #   end
  #   true
  # end

  # def ip6_normalize!
  #   if ip6_network
  #     ip6_network_addr = IPAddress::IPv6.new(ip6_network)

  #     if ip6_network_addr.network?
  #       errors.add(:ip6_address, 'ネットワークアドレスではありません。')
  #       return false
  #     end

  #     self.ip6_address = ip6_network_addr.address
  #     self.ip6_prefix = ip6_network_addr.prefix

  #     if ip6_gateway.present?
  #       ip6_gateway_addr = IPAddress::IPv4.new(ip6_gateway)
  #       unless ip6_network_addr.include?(ip6_gateway_addr)
  #         errors.add(:ip6_gateway, 'ネットワークの範囲外です。')
  #         return false
  #       end
  #       self.ip6_gateway = ip6_gateway_addr.address
  #     else
  #       self.ip6_gateway = nil
  #     end
  #   else
  #     self.ip6_address = nil
  #     self.ip6_prefix = nil
  #     self.ip6_gateway = nil
  #   end
  #   true
  # end

  # # 空いている次のIPアドレス
  # def ip_next(ip_config: nil)
  #   return unless ip_network

  #   ip_config = ip_config&.to_s

  #   ip_network_addr = IPAddress::IPv4.new(ip_network)
  #   ip_gateway_addr = ip_gateway.presence || IPAddress::IPv4.new(ip_gateway)

  #   if ip_config
  #     selected_ip_pools = ip_pools
  #       .select {|ip_pool| ip_pool.ip_config == ip_config}
  #     nics_addrs = nics.map do |nic|
  #       nic.ip_address.presence && IPAddress::IPv4.new(nic.ip_address)
  #     end.compact
  #   end

  #   (ip_network_addr.first..ip_network_addr.last).find do |addr|
  #     addr.prefix = 32

  #     next if addr == ip_gateway_addr

  #     if ip_config
  #       selected_ip_pools.any? { |ip_pool| ip_pool.include?(addr) } &&
  #         !nics_addrs.include?(addr)
  #     else
  #       ip_pools.all? do |ip_pool|
  #         !ip_pool.include?(addr)
  #       end
  #     end
  #   end
  # end

  # def ip6_next(ip6_config: nil)
  #   return unless ip6_network

  #   ip6_config = ip6_config&.to_s

  #   ip6_network_addr = IPAddress::IPv6.new(ip6_network)
  #   ip6_gateway_addr = ip6_gateway.presence || IPAddress::IPv6.new(ip6_gateway)

  #   if ip6_config
  #     selected_ip6_pools = ip6_pools
  #       .select {|ip6_pool| ip6_pool.ip6_config == ip6_config}
  #     nics_addrs = nics.map do |nic|
  #       nic.ip6_address.presence && IPAddress::IPv6.new(nic.ip6_address)
  #     end.compact
  #   end

  #   (ip6_network_addr.first..ip6_network_addr.last).find do |addr|
  #     addr.prefix = 32

  #     next if addr == ip6_gateway_addr

  #     if ip6_config
  #       selected_ip6_pools.any? { |ip6_pool| ip6_pool.include?(addr) } &&
  #         !nics_addrs.include?(addr)
  #     else
  #       ip6_pools.all? do |ip6_pool|
  #         !ip6_pool.include?(addr)
  #       end
  #     end
  #   end
  # end

  # def available_ip_configs
  #   configs = IpPool.ip_configs.transform_values { |_| 0 }
  #   ip_pools.each do |ip_pool|
  #     configs[ip_pool.ip_config] += 1
  #   end
  #   configs
  # end

  # def available_ip6_configs
  #   configs = Ip6Pool.ip6_configs.transform_values { |_| 0 }
  #   ip6_pools.each do |ip6_pool|
  #     configs[ip6_pool.ip6_config] += 1
  #   end
  #   configs
  # end

end
