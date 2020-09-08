class Subnetwork < ApplicationRecord
  belongs_to :network_category
  has_many :ip_networks, dependent: :destroy
  has_many :network_connections, dependent: :destroy

  has_many :subnetwork_users, dependent: :destroy

  has_many :users, through: :subnetwork_users
  has_many :network_interfaces, through: :network_connections
end
