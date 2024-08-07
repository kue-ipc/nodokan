# rubocop: disable Metrics
class Network < ApplicationRecord
  include ListJsonData
  include ReplaceError

  IP_MASKS = (0..32).map { |i| IPAddr.new("0.0.0.0").mask(i).netmask }

  FLAGS = {
    auth: "a",
    dhcp: "d",
    locked: "l",
    specific: "s",
  }.freeze

  IDENTIFIER_TYPES = {
    vlan: "v",
    ipv4: "i",
    ipv6: "k",
    id: "#",
  }.freeze

  has_paper_trail

  enum :ra, {
    disabled: -1,
    router: 0b000,
    unmanaged: 0b100, # A
    managed: 0b011, # M+O
    assist: 0b111, # M+O+A
    stateless: 0b110, # O+A
  }, prefix: true, validate: true

  has_many :nics, dependent: :nullify
  has_many :nodes, through: :nics

  has_many :ipv4_pools, -> { order(ipv4_first_data: :asc) },
    dependent: :destroy, inverse_of: :network
  accepts_nested_attributes_for :ipv4_pools, allow_destroy: true
  has_many :ipv6_pools, -> { order(ipv6_first_data: :asc) },
    dependent: :destroy, inverse_of: :network
  accepts_nested_attributes_for :ipv6_pools, allow_destroy: true

  has_many :assignments, dependent: :destroy
  has_many :auth_assignments, -> { where(auth: true).readonly },
    class_name: "Assignment", inverse_of: :network
  has_many :use_assignments, -> { where(use: true).readonly },
    class_name: "Assignment", inverse_of: :network
  has_many :manage_assignments, -> { where(manage: true).readonly },
    class_name: "Assignment", inverse_of: :network

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

  validates :domain, allow_nil: true, domain: true

  validates :ipv4_network_address, allow_blank: true, ipv4_address: true
  validates :ipv4_gateway_address, allow_blank: true, ipv4_address: true
  validates :ipv6_network_address, allow_blank: true, ipv6_address: true
  validates :ipv6_gateway_address, allow_blank: true, ipv6_address: true

  validates :ipv4_network_data, allow_nil: true, uniqueness: true
  validates :ipv6_network_data, allow_nil: true, uniqueness: true
  validates :ipv4_network_data, presence: true, if: :dhcp
  validates :ipv6_network_data, presence: true, unless: :ra_disabled?

  validates :ipv4_gateway_data, absence: true, unless: :ipv4_network_data
  validates :ipv6_gateway_data, absence: true, unless: :ipv6_network_data

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

  validates :ipv4_pools, absence: true, unless: :has_ipv4?
  validates :ipv6_pools, absence: true, unless: :has_ipv6?

  validates_each :ipv4_gateway do |record, attr, value|
    if value && record.has_ipv4?
      network_range = record.ipv4_network.to_range
      if !network_range.cover?(value)
        record.errors.add(attr, I18n.t("errors.messages.out_of_network"))
      elsif network_range.begin == value
        record.errors.add(attr, I18n.t("errors.messages.network_address"))
      elsif network_range.end == value
        record.errors.add(attr, I18n.t("errors.messages.broadcast_address"))
      end
    end
  end

  validates_each :ipv6_gateway do |record, attr, value|
    # IPv6では全てのアドレスもホストに設定可能
    if value && record.has_ipv6? && !record.ipv6_network.include?(value)
      record.errors.add(attr, I18n.t("errors.messages.out_of_network"))
    end
  end

  normalizes :domain, with: ->(str) { str.presence&.strip&.downcase }

  list_json_data :domain_search, validate: :domain,
    normalize: ->(str) { str.presence&.strip&.downcase }
  # rubocop: disable Style/RescueModifier
  list_json_data :ipv4_dns_servers, validate: :ipv4_address,
    normalize: ->(str) { IPAddr.new(str).to_s rescue str }
  list_json_data :ipv6_dns_servers, validate: :ipv6_address,
    normalize: ->(str) { IPAddr.new(str).to_s rescue str }
  # rubocop: enable Style/RescueModifier

  after_validation :replace_network_errors

  after_commit :kea_subnet4, :kea_subnet6

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w(name vlan ipv4_network_data ipv6_network_data auth nics_count
      assignments_count)
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
  # rubocop: enable Lint/UnusedMethodArgument

  attribute :global, :boolean
  def global
    (ipv4_network_data.present? && !ipv4_network.private?) ||
      (ipv6_network_data.present? && !ipv6_network.private?)
  end
  alias global? global

  # IPv4

  # rubocop: disable Naming/PredicateName
  def has_ipv4?
    ipv4_network_data.present?
  end
  # rubocop: enable Naming/PredicateName

  def dhcpv4?
    dhcp
  end

  # network with prefix
  def ipv4_network
    ipv4_network_data &&
      IPAddr.new_ntoh(ipv4_network_data).mask(ipv4_prefix_length)
  end

  def ipv4_network=(value)
    case value
    when IPAddr
      self.ipv4_network_data = value&.hton
      self.ipv4_prefix_length = value&.prefix || 0
    when %r{/}
      self.ipv4_network_cidr = value
    else
      self.ipv4_network_address = value
    end
  end

  attribute :ipv4_network_address, :string
  def ipv4_network_address
    ipv4_network&.to_s || @ipv4_network_address
  end

  def ipv4_network_address=(value)
    @ipv4_network_address = value
    self.ipv4_network_data = value.presence && IPAddr.new(value).hton
  rescue IPAddr::InvalidAddressError
    self.ipv4_network_data = nil
  end

  def ipv4_netmask
    ipv4_prefix_length && IPAddr.new("0.0.0.0").mask(ipv4_prefix_length).netmask
  end

  def ipv4_netmask=(value)
    self.ipv4_prefix_length =
      value.presence && IPAddr.new("0.0.0.0/#{value}").prefix
  end

  # cdir = address/prefix
  def ipv4_network_cidr
    ipv4_network_data && "#{ipv4_network_address}/#{ipv4_prefix_length}"
  end

  def ipv4_network_cidr=(value)
    address, length = value.split("/", 2)
    self.ipv4_network_address = address
    self.ipv4_prefix_length = length.to_i
  end

  # address/netmask
  def ipv4_network_address_netmask
    ipv4_network_data && "#{ipv4_network_address}/#{ipv4_netmask}"
  end

  def ipv4_gateway
    ipv4_gateway_data && IPAddr.new_ntoh(ipv4_gateway_data)
  end

  def ipv4_gateway=(value)
    if value.is_a?(IPAddr)
      self.ipv4_gateway_data = value&.hton
    else
      self.ipv4_gateway_address = value
    end
  end

  attribute :ipv4_gateway_address, :string
  def ipv4_gateway_address
    ipv4_gateway&.to_s || @ipv4_gateway_address
  end

  def ipv4_gateway_address=(value)
    @ipv4_gateway_address = value
    self.ipv4_gateway = value.presence && IPAddr.new(value)
  rescue IPAddr::InvalidAddressError
    self.ipv4_gateway = nil
  end

  # Ipv6

  # rubocop: disable Naming/PredicateName
  def has_ipv6?
    ipv6_network_data.present?
  end
  # rubocop: enable Naming/PredicateName

  def dhcpv6?
    ["managed", "assist", "stateless"].include?(ra)
  end

  def slaac?
    ["assist", "stateless"].include?(ra)
  end

  # network with prefix
  def ipv6_network
    ipv6_network_data &&
      IPAddr.new_ntoh(ipv6_network_data).mask(ipv6_prefix_length)
  end

  def ipv6_network=(value)
    case value
    when IPAddr
      self.ipv6_network_data = value&.hton
      self.ipv6_prefix_length = value&.prefix || 0
    when %r{/}
      self.ipv6_network_cidr = value
    else
      self.ipv6_network_address = value
    end
  end

  attribute :ipv6_network_address, :string
  def ipv6_network_address
    ipv6_network&.to_s || @ipv6_network_address
  end

  def ipv6_network_address=(value)
    @ipv6_network_address = value
    self.ipv6_network_data = value.presence && IPAddr.new(value).hton
  rescue IPAddr::InvalidAddressError
    self.ipv6_network = nil
  end

  # cidr = address/prefix
  def ipv6_network_cidr
    ipv6_network_data && "#{ipv6_network_address}/#{ipv6_prefix_length}"
  end

  def ipv6_network_cidr=(value)
    address, length = value.split("/", 2)
    self.ipv6_network_address = address
    self.ipv6_prefix_length = length.to_i
  end

  def ipv6_gateway
    ipv6_gateway_data && IPAddr.new_ntoh(ipv6_gateway_data)
  end

  def ipv6_gateway=(value)
    if value.is_a?(IPAddr)
      self.ipv6_gateway_data = value&.hton
    else
      self.ipv6_gateway_address = value
    end
  end

  attribute :ipv6_gateway_address, :string
  def ipv6_gateway_address
    ipv6_gateway&.to_s || @ipv6_gateway_address
  end

  def ipv6_gateway_address=(value)
    @ipv6_gateway_address = value
    self.ipv6_gateway = value.presence && IPAddr.new(value)
  rescue IPAddr::InvalidAddressError
    self.ipv6_gateway = nil
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
    elsif has_ipv4?
      "i#{ipv4_network_address}"
    elsif has_ipv6?
      "k#{ipv6_network_address}"
    else
      "##{id}"
    end
  end

  # 空いている次のIPアドレス
  def next_ipv4(ipv4_config)
    return unless ipv4_network

    selected_ipv4_pools = ipv4_pools.where(ipv4_config: ipv4_config)
      .order(:ipv4_first_data)
    return if selected_ipv4_pools.empty?

    nics_ipv4_set = nics.map(&:ipv4).compact.to_set
    ipv4_gateway = self.ipv4_gateway

    selected_ipv4_pools.each do |ipv4_pool|
      ipv4_pool.each do |ipv4|
        return ipv4 if ipv4 != ipv4_gateway && nics_ipv4_set.exclude?(ipv4)
      end
    end

    nil
  end

  def next_ipv6(ipv6_config)
    return unless ipv6_network

    selected_ipv6_pools =
      ipv6_pools.where(ipv6_config: ipv6_config).order(:ipv6_first_data)
    return if selected_ipv6_pools.empty?

    nics_ipv6_set = nics.map(&:ipv6).compact.to_set
    ipv6_gateway = self.ipv6_gateway

    selected_ipv6_pools.each do |ipv6_pool|
      ipv6_pool.each do |ipv6|
        return ipv6 if ipv6 != ipv6_gateway && nics_ipv6_set.exclude?(ipv6)
      end
    end

    nil
  end

  def mapped_ipv6(ipv4)
    return unless ipv4

    mapped_ipv6_pool = ipv6_pools.find_by(ipv6_config: "mapped")
    return unless mapped_ipv6_pool

    IPAddr.new(mapped_ipv6_pool.ipv6_first.to_i + ipv4.to_i, Socket::AF_INET6)
  end

  def ipv4_configs
    @ipv4_configs ||=
      ipv4_pools.map(&:ipv4_config)
        .then { |list| (list + ["manual", "disabled"]).uniq }
  end

  def ipv6_configs
    @ipv6_configs ||=
      ipv6_pools.map(&:ipv6_config)
        .then { |list| (list + ["manual", "disabled"]).uniq }
  end

  def ipv4_include?(ipv4)
    return false unless ipv4_network

    ipv4_network.include?(ipv4)
  end

  def ipv6_include?(ipv6)
    return false unless ipv6_network

    ipv6_network.include?(ipv6)
  end

  def flag
    FLAGS.map { |attr, c| self[attr].presence && c }.compact.join.presence
  end

  def flag=(str)
    FLAGS.each { |attr, c| self[attr] = true & str&.include?(c) }
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

  def kea_subnet4
    if !destroyed? && has_ipv4? && dhcpv4?
      options = {
        routers: ipv4_gateway,
        domain_name_servers: ipv4_dns_servers_data,
        domain_name: domain,
        domain_search: domain_search_data,
      }.compact_blank
      KeaSubnet4AddJob.perform_later(id, ipv4_network, options,
        ipv4_pools.where(ipv4_config: "dynamic").map(&:ipv4_range))
    else
      KeaSubnet4DelJob.perform_later(id)
    end
  end

  def kea_subnet6
    if !destroyed? && has_ipv6? && dhcpv6?
      options = {
        dns_servers: ipv6_dns_servers_data,
        domain_search: [domain, *domain_search_data].compact_blank,
      }.compact_blank
      KeaSubnet6AddJob.perform_later(id, ipv6_network, options,
        ipv6_pools.where(ipv6_config: "dynamic").map(&:ipv6_range))
    else
      KeaSubnet6DelJob.perform_later(id)
    end
  end

  private def replace_network_errors
    replace_error(:ipv4_network_data, :ipv4_network_address)
    replace_error(:ipv4_network, :ipv4_network_address)
    replace_error(:ipv4_gateway_data, :ipv4_gateway_address)
    replace_error(:ipv4_gateway, :ipv4_gateway_address)
    replace_error(:ipv6_network_data, :ipv6_network_address)
    replace_error(:ipv6_network, :ipv6_network_address)
    replace_error(:ipv6_gateway_data, :ipv6_gateway_address)
    replace_error(:ipv6_gateway, :ipv6_gateway_address)
 end

  # class methods

  def self.find_identifier(str)
    m = /\A(?<type>.)(?<value>[\h]+)\z/.match(str.to_s.strip.downcase)
    raise ArgumentError, "Invalid identifier format #{str.inspect}" unless m

    case m[:type]
    when "v"
      Network.find_by(vlan: m[:value].to_i)
    when "i", "k"
      value = IPAddr.new(m[:value])
      if value.ipv4?
        Network.find_by(ipv4_network_data: value.hton)
      elsif value.ivp6?
        Network.find_by(ipv6_network_data: value.hton)
      else
        raise ArgumentError, "Unknown ip version #{str.inspect}"
      end
    when "#"
      Network.find_by(id: m[:value].to_i)
    else
      raise ArgumentError, "Unknown identifier type #{str.inspect}"
    end
  end

  def self.next_free_auth
    Network
      .where(auth: true, locked: false, nics_count: 0, assignments_count: 0)
      .order(:vlan)
      .first
  end
end
