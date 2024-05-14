class Ipv4Arp < ApplicationRecord
  include Ipv4Data
  include MacAddressData

  validates :ipv4_data, length: {is: 4}
  validates :mac_address_data, length: {is: 6}

  alias_attribute :resolved_at, :end_at
end
