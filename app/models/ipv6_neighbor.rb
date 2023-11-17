class Ipv6Neighbor < ApplicationRecord
  include Ipv6Data
  include MacAddressData

  validates :mac_address_data, uniqueness: {scope: :ipv6_data}
end
