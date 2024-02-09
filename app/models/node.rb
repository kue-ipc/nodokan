class Node < ApplicationRecord
  include DuidData

  FLAGS = {
    specific: "s",
    logical: "l",
    public: "p",
    dns: "d",
  }.freeze

  belongs_to :user, counter_cache: true

  belongs_to :place, optional: true, counter_cache: true
  belongs_to :hardware, optional: true, counter_cache: true
  belongs_to :operating_system, optional: true, counter_cache: true

  belongs_to :host, class_name: "Node", foreign_key: "node_id", inverse_of: :guests
  has_many :guests, class_name: "Node", foreign_key: "host_id", dependent: :restrict_with_error, inverse_of: :host

  has_many :logical_compositions, dependent: :restrict_with_error
  has_many :components, through: :logical_compositions
  # , source_type: "Node"

  has_many :composed_compositions, class_name: "LogicalComposition", foreign_key: "component_id",
    dependent: :restrict_with_error, inverse_of: :component
  has_many :nodes, through: :composed_compositions

  has_many :nics, -> { order(:number) }, dependent: :destroy, inverse_of: :node
  accepts_nested_attributes_for :nics, allow_destroy: true

  has_one :confirmation, dependent: :destroy

  validates :name, presence: true
  validates :hostname, allow_nil: true,
    format: {
      with: /\A(?!-)[0-9a-z-]+(?<!-)\z/i,
    }
  validates :domain,
    allow_nil: true,
    format: {
      with: /\A(?<name>(?!-)[0-9a-z-]+(?<!-))(?:\.\g<name>)*\z/i,
    }
  validates :duid, allow_blank: true, duid: true

  normalizes :hostname, with: :strip.to_proc >> :downcase.to_proc
  normalizes :domain, with: :strip.to_proc >> :downcase.to_proc

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w(
      name
      hostname
      domain
      specific
      logical
      pubilc
      dns
      duid_data
      user_id
      virtual_machine
    )
  end

  def self.ransackable_associations(auth_object = nil)
    %w(user place hardware operating_system nics)
  end

  # rubocop: enable Lint/UnusedMethodArgument

  def global?
    nics.any?(&:global?)
  end
  alias global global?

  def fqdn
    return if hostname.blank?

    return hostname if domain.blank?

    "#{hostname}.#{domain}"
  end

  def logical?
    logical
  end

  def flag
    FLAGS.map { |attr, c| self[attr].presence && c }.compact.join.presence
  end

  def flag=(str)
    FLAGS.each { |attr, c| self[attr] = true & str&.include?(c) }
  end

  def connected_at
    return @connected_at if @connected_at_checked

    @connected_at = nics.flat_map do |nic|
      [:ipv4_resolved_at, :ipv6_discovered_at, :ipv4_leased_at, :ipv6_leased_at, :auth_at].map { |name| nic[name] }
    end.compact.max
    @connected_at_checked = true
    @connected_at
  end

  def to_s
    name
  end
end
