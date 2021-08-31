class Node < ApplicationRecord
  FLAGS = {
    specific: 's',
    virtual: 'v',
    pulbic: 'p',
    dns: 'd'
  }.freeze

  belongs_to :user, counter_cache: true

  belongs_to :place, optional: true, counter_cache: true
  belongs_to :hardware, optional: true, counter_cache: true
  belongs_to :operating_system, optional: true, counter_cache: true

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

  normalize_attribute :hostname, with: [:strip, :blank, :downcase]
  normalize_attribute :domain, with: [:strip, :blank, :downcase]
  normalize_attribute :note

  def global?
    nics.any?(&:global?)
  end
  alias global global?

  def fqdn
    return if hostname.blank?

    return hostname if domain.blank?

    "#{hostname}.#{domain}"
  end

  def virutal?
    virtual
  end

  def physical?
    !virtual
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
      %i[ipv4_resolved_at ipv6_discovered_at ipv4_leased_at ipv6_leased_at auth_at].map { |name| nic[name] }
    end.compact.max
    @connected_at_checked = true
    @connected_at
  end
end
