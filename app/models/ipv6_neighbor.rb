class Ipv6Neighbor < ApplicationRecord
  include Ipv6Data
  include MacAddressData

  validates :ipv6_data, length: {is: 16}
  validates :mac_address_data, length: {is: 6}
  validates :discovered_at, presence: true

  alias_attribute :discovered_at, :end_at

  before_save :set_begin_at

  def set_begin_at
    return unless begin_at.nil?

    self.begin_at = end_at
  end
end
