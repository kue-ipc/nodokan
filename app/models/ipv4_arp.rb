class Ipv4Arp < ApplicationRecord
  include Ipv4Data
  include MacAddressData

  validates :ipv4_data, length: {is: 4}
  validates :mac_address_data, length: {is: 6}
  validates :resolved_at, presence: true

  alias_attribute :resolved_at, :end_at

  before_save :set_begin_at

  def set_begin_at
    return unless begin_at.nil?

    self.begin_at = end_at
  end
end
