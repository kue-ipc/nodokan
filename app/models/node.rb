class Node < ApplicationRecord
  belongs_to :user

  belongs_to :place, optional: true, counter_cache: true
  belongs_to :hardware, optional: true, counter_cache: true
  belongs_to :operating_system, optional: true, counter_cache: true
  belongs_to :security_software, optional: true, counter_cache: true

  has_many :network_interfaces, dependent: :destroy
  accepts_nested_attributes_for :network_interfaces, allow_destroy: true

  validates :name, presence: true
  validates :hostname, allow_nil: true,
            format: { with: /\A(?!-)[0-9a-z-]+(?<!-)\z/i }
  validates :domain, allow_nil: true,
            format: { with: /\A(?<name>(?!-)[0-9a-z-]+(?<!-))(?:\.\g<name>)*\z/i }

  normalize_attribute :hostname, with: [:nilify, :downcase]
  normalize_attribute :domain, with: [:nilify, :downcase]
  normalize_attribute :note, :nilify

  def fqdn
    return if hostname.blank?

    return hostname if domain.blank?

    "#{hostname}.#{domain}"
  end
end
