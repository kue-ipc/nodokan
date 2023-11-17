class Ipv4Arp < ApplicationRecord
  include Ipv4Data
  include MacAddressData

  validates :mac_address_data, uniqueness: {scope: :ipv4_data}
end
