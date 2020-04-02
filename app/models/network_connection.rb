class NetworkConnection < ApplicationRecord
  belongs_to :network_interface
  belongs_to :subnetwork
  has_many :ipv4_addresses
  has_many :ipv6_addresses
end
