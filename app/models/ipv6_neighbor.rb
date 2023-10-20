class Ipv6Neighbor < ApplicationRecord
  validates :mac_address_data, uniqueness: {scope: :ipv6_data}
end
