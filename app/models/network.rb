# rubocop: disable Metrics
class Network < ApplicationRecord
  IP_MASKS = (0..32).map { |i| IPAddr.new("0.0.0.0").mask(i).netmask }

  FLAGS = {
    auth: "a",
    dhcp: "d",
    locked: "l",
    specific: "s",
  }.freeze

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

  validates :ipv4_network_address, allow_blank: true, ipv4_address: true
  validates :ipv4_gateway_address, allow_blank: true, ipv4_address: true
  validates :ipv6_network_address, allow_blank: true, ipv6_address: true
  validates :ipv6_gateway_address, allow_blank: true, ipv6_address: true

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

  validates :ipv4_pools, absence: true, if: -> { !ipv4? }
  validates :ipv6_pools, absence: true, if: -> { !ipv6? }

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

  def global?
    (ipv4_network_data.present? && !ipv4_network.private?) ||
      (ipv6_network_data.present? && !ipv6_network.private?)
  end
  alias global global?

  # IPv4

  def ipv4?
    ipv4_network_data.present?
  end

  # readonly
  def ipv4_network
    ipv4_network_data && IPAddr.new_ntoh(ipv4_network_data).mask(ipv4_prefix_length)
  end

  def ipv4_network_address
    ipv4_network&.to_s
  end

  # value allow blank
  def ipv4_network_address=(value)
    self.ipv4_network_data = value.presence && IPAddr.new(value).hton
  end

  # address/prefix
  def ipv4_network_address_prefix
    ipv4_network_data && "#{ipv4_network_address}/#{ipv4_prefix_length}"
  end

  def ipv4_netmask
    ipv4_prefix_length && IPAddr.new("0.0.0.0").mask(ipv4_prefix_length).netmask
  end

  # address/netmask
  def ipv4_network_address_netmask
    ipv4_network_data && "#{ipv4_network_address}/#{ipv4_netmask}"
  end

  # value allow blank
  def ipv4_netmask=(value)
    self.ipv4_prefix_length = value.presence && IPAddr.new("0.0.0.0/#{value}").prefix
  end

  # readonly
  def ipv4_gateway
    ipv4_gateway_data && IPAddr.new_ntoh(ipv4_gateway_data)
  end

  def ipv4_gateway_address
    ipv4_gateway&.to_s
  end

  def ipv4_gateway_address=(value)
    self.ipv4_gateway_data = value.presence && IPAddr.new(value).hton
  end

  # Ipv6

  def ipv6?
    ipv6_network_data.present?
  end

  # readonly
  def ipv6_network
    ipv6_network_data && IPAddr.new_ntoh(ipv6_network_data).mask(ipv6_prefix_length)
  end

  def ipv6_network_address
    ipv6_network&.to_s
  end

  # vaule allow blank
  def ipv6_network_address=(value)
    self.ipv6_network_data = value.presence && IPAddr.new(value).hton
  end

  # address/prefix
  def ipv6_network_address_prefix
    ipv6_network_data && "#{ipv6_network_address}/#{ipv6_prefix_length}"
  end

  # readonly
  def ipv6_gateway
    ipv6_gateway_data && IPAddr.new_ntoh(ipv6_gateway_data)
  end

  def ipv6_gateway_address
    ipv6_gateway&.to_s
  end

  # value allow blank
  def ipv6_gateway_address=(value)
    self.ipv6_gateway_data = value.presence && IPAddr.new(value).hton
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
      "##{id}"
    end
  end

  # 空いている次のIPアドレス
  def next_ipv4(ipv4_config)
    return unless ipv4_network

    selected_ipv4_pools = ipv4_pools.where(ipv4_config: ipv4_config).order(:ipv4_first_data)
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

    selected_ipv6_pools = ipv6_pools.where(ipv6_config: ipv6_config).order(:ipv6_first_data)
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
    if !destroyed? && dhcp && ipv4_network
      KeaSubnet4AddJob.perform_later(self)
    else
      KeaSubnet4DelJob.perform_later(self)
    end
  end

  def kea_subnet6
    # TODO
  end

  def to_s
    name
  end

  # class methods

  def self.find_identifier(str)
    case str.to_s.strip.downcase
    when /^v(\d{1,4})$/
      Network.find_by(vlan: Regexp.last_match(1).to_i)
    when /^i([.\d]+)$/
      Network.find_by(ipv4_network_data: IPAddr.new(Regexp.last_match(1)).hton)
    when /^k([:\h]+)$/
      Network.find_by(ipv6_network_data: IPAddr.new(Regexp.last_match(1)).hton)
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
