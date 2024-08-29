class Node < ApplicationRecord
  include DuidData
  include UniqueIdentifier
  include Flag

  unique_identifier "@",
    read: ->(record) { record.fqdn if record.domain.present? },
    find: ->(value) {
            hostname, domain = value.split(".", 2)
            raise ArgumentError, "No domain in fqdn: #{str}" if domain.nil?

            find_by!(hostname: hostname, domain: domain)
          }
  unique_identifier "i",
    read: ->(record) { record.nics.find(&:has_ipv4?)&.ipv4_address },
    find: ->(value) { Nic.find_ip_address(value).node }
  unique_identifier "k",
    read: ->(record) { record.nics.find(&:has_ipv6?)&.ipv6_address },
    find: ->(value) { Nic.find_ip_address(value).node }

  flag :flag, {
    specific: "s",
    public: "p",
    dns: "d",
  }

  has_paper_trail

  enum :node_type, [:normal, :mobile, :virtual, :logical], validate: true

  belongs_to :user, optional: true, counter_cache: true

  belongs_to :place, optional: true, counter_cache: true, validate: true
  belongs_to :hardware, optional: true, counter_cache: true, validate: true
  belongs_to :operating_system, optional: true, counter_cache: true,
    validate: true

  belongs_to :host, optional: true, class_name: "Node", inverse_of: :guests
  has_many :guests, dependent: :restrict_with_error, class_name: "Node",
    foreign_key: "host_id", inverse_of: :host

  has_many :logical_compositions, dependent: :destroy
  has_many :components, through: :logical_compositions

  has_many :composed_compositions, dependent: :destroy,
    class_name: "LogicalComposition", foreign_key: "component_id",
    inverse_of: :component
  has_many :logical_nodes, through: :composed_compositions, source: :node

  has_many :nics, -> { order(:number) }, dependent: :destroy, inverse_of: :node
  accepts_nested_attributes_for :nics, allow_destroy: true

  has_one :confirmation, dependent: :destroy

  validates :name, presence: true
  validates :hostname, allow_nil: true, hostname: true
  validates :domain, allow_nil: true, domain: true

  validates :hostname, presence: true,
    uniqueness: {scope: :domain, case_sensitive: true},
    if: ->(node) { node.domain.present? }
  validates :duid_data, allow_nil: true, length: {minimum: 2}, uniqueness: true

  validates :nics,
    length: {minimum: 1, too_short: I18n.t("errors.messages.item_too_short")},
    if: -> { Settings.config.node_require_nic }

  normalizes :hostname, with: ->(str) { str.presence&.strip&.downcase }
  normalizes :domain, with: ->(str) { str.presence&.strip&.downcase }

  before_save :reset_attributes_for_node_type

  # class methods

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w(
      name
      hostname
      domain
      node_type
      specific
      pubilc
      dns
      duid_data
      user_id
    )
  end

  def self.ransackable_associations(auth_object = nil)
    %w(nics)
  end
  # rubocop: enable Lint/UnusedMethodArgument

  attribute :global, :boolean
  def global
    nics.any?(&:global)
  end
  alias global? global

  def fqdn
    return if hostname.blank?

    return hostname if domain.blank?

    "#{hostname}.#{domain}"
  end

  def fqdn=(str)
    if str.blank?
      self.hostname = nil
      self.domain = nil
    else
      list = str.split(".", 2)
      self.hostname = list[0]
      self.domain = list[1]
    end
  end

  def connected_at
    return @connected_at if @connected_at_checked

    @connected_at = nics.flat_map do |nic|
      [
        :ipv4_resolved_at,
        :ipv6_discovered_at,
        :ipv4_leased_at,
        :ipv6_leased_at,
        :auth_at,
      ].map { |name| nic[name] }
    end.compact.max
    @connected_at_checked = true
    @connected_at
  end

  private def reset_attributes_for_node_type
    case node_type
    when "normal"
      self.host = nil
      components.clear
    when "mobile"
      self.place = nil
      self.host = nil
      components.clear
    when "virtual"
      self.place = nil
      components.clear
    when "logical"
      self.host = nil
      self.place =  nil
      self.hardware = nil
      self.operating_system = nil
    else
      raise "unknown node type: #{node_type}"
    end
  end
end
