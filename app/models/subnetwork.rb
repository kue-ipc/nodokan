class Subnetwork < ApplicationRecord
  belongs_to :network_type
  has_many :ipv4_network, dependent: :destroy
  has_many :ipv6_network, dependent: :destroy
end