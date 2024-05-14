class Ipv6Neighbor < ApplicationRecord
  include Ipv6Data
  include MacAddressData

  validates :ipv6_data, length: {is: 16}
  validates :mac_address_data, length: {is: 6}

  alias_attribute :discovered_at, :end_at
end
