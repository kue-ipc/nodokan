class Ipv4Arp < ApplicationRecord
  validates :mac_address_data, uniqueness: {scope: :ipv4_data}
end
