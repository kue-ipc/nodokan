class Subnetwork < ApplicationRecord
  belongs_to :network_category
  has_many :ip_networks, dependent: :destroy
  has_many :ip_pools, dependent: :destroy
end
