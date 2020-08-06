class NetworkConnection < ApplicationRecord
  belongs_to :network_interface
  belongs_to :subnetwork
  has_many :ip_addresses
end
