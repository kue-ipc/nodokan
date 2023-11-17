class Ipv4Arp < ApplicationRecord
  include Ipv4Data

  validates :mac_address_data, uniqueness: {scope: :ipv4_data}
end
