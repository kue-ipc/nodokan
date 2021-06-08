class Node < ApplicationRecord
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

  def fqdn
    return if hostname.blank?

    return hostname if domain.blank?

    "#{hostname}.#{domain}"
  end
end
