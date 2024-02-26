class Ipv4Arp < ApplicationRecord
  include Ipv4Data
  include MacAddressData

  validates :ipv4_data, length: {is: 4}
  validates :mac_address_data, length: {is: 6}, uniqueness: {scope: :ipv4_data}
end
