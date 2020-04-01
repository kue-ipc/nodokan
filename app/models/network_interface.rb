class NetworkInterface < ApplicationRecord
  belongs_to :node
  has_many :network_connections
  has_many :subnetworks, through: :network_connections
end
