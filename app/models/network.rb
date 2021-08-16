class Network < ApplicationRecord
  IP_MASKS = (0..32).map do |i|
    IPAddress::Prefix32.new(i).to_ip
  end

  FLAGS = {
    auth: 'a',
    dhcp: 'd',
    locked: 'l',
    specific: 's',
  }.freeze

  has_many :nics, dependent: :nullify
  has_many :nodes, through: :nics

  has_many :ipv4_pools, dependent: :destroy
  accepts_nested_attributes_for :ipv4_pools, allow_destroy: true
  has_many :ipv6_pools, dependent: :destroy
  accepts_nested_attributes_for :ipv6_pools, allow_destroy: true

  has_many :assignments, dependent: :destroy
  has_many :auth_assignments, -> { where(auth: true).readonly }, class_name: 'Assignment', inverse_of: :network
  has_many :use_assignments, -> { where(use: true).readonly }, class_name: 'Assignment', inverse_of: :network
  has_many :manage_assignments, -> { where(manage: true).readonly }, class_name: 'Assignment', inverse_of: :network

  has_many :users, through: :assignments
  has_many :auth_users, through: :auth_assignments, source: :user
  has_many :use_users, through: :use_assignments, source: :user
  has_many :manage_users, through: :manage_assignments, source: :user

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

  validates :ipv4_netmask, allow_blank: true, inclusion: { in: IP_MASKS }

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

  after_commit :kea_subnet4, :kea_subnet6

  # IPv4

  # readonly
  def ipv4_network
    @ipv4_network ||=
      ipv4_network_data.presence &&
      IPAddress::IPv4.parse_data(ipv4_network_data, ipv4_prefix_length)
  end

  def ipv4_network_prefix
    ipv4_network&.to_string
  end

  def ipv4_network_address
    @ipv4_network_address ||= (ipv4_network&.to_s || '')
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
    @ipv4_gateway_address ||= (ipv4_gateway&.to_s || '')
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

  def ipv6_network_prefix
    ipv6_network&.to_string
  end

  def ipv6_network_address
    @ipv6_network_address ||= (ipv6_network&.to_s || '')
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
      IPAddress::IPv6.parse_hex(ipv6_gateway_data.unpack('H*').first, ipv6_prefix_length)
  end

  def ipv6_gateway_address
    @ipv6_gateway_address ||= (ipv6_gateway&.to_s || '')
  end

  def ipv6_gateway_address=(value)
    @ipv6_gateway_address = value
    self.ipv6_gateway_data = @ipv6_gateway_address.presence &&
                             IPAddress::IPv6.new(@ipv6_gateway_address).data
  rescue ArgumentError
    self.ipv6_gateway_data = nil
  end

  # string
  def name_vlan
    if vlan.present?
      "#{name} (VLAN #{vlan})"
    else
      name
    end
  end

  def identifier
    if vlan
      "v#{vlan}"
    elsif ipv4_network
      "i#{ipv4_network_address}"
    elsif ipv6_network
      "k#{ipv6_network_address}"
    else
      "\##{id}"
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

    (ipv6_network.first..ipv6_network.last).find do |ipv6|
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

  def kea_subnet4
    if !destroyed? && dhcp && ipv4_network
      KeaSubnet4AddJob.perform_later(self)
    else
      KeaSubnet4DelJob.perform_later(self)
    end
  end

  def kea_subnet6
    # TODO
  end

  def flag
    FLAGS.map { |attr, c| self[attr] ? c : nil }.compact.join.presence
  end

  def flag=(str)
    FLAGS.each { |attr, c| self[attr] = str.present? && str.include?(c) }
  end

  def auth?(user)
    auth_users.exists?(user.id)
  end

  def usable?(user)
    user.admin? || use_users.exists?(user.id)
  end

  def manageable?(user)
    user.admin? || manage_users.exists?(user.id)
  end

  # class methods

  def self.find_identifier(str)
    case str.to_s.strip.downcase
    when /^v(\d{1,4})$/
      Network.find_by(vlan: Regexp.last_match(1).to_i)
    when /^i([.\d]+)$/
      Network.find_by(ipv4_network_data: IPAddress::IPv4.new(Regexp.last_match(1)).data)
    when /^k([:\h]+)$/
      Network.find_by(ipv6_network_data: IPAddress::IPv6.new(Regexp.last_match(1)).data)
    when /^\#(\d+)$/
      Network.find(Regexp.last_match(1).to_i)
    else
      logger.warn "Invalid network identifier: #{str}"
      nil
    end
  end

  def self.next_free
    Network
      .where(auth: true, locked: false, nics_count: 0, assignments_count: 0)
      .order(:vlan)
      .first
  end
end
