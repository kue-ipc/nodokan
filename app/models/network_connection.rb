class NetworkConnection < ApplicationRecord
  belongs_to :network_interface
  belongs_to :subnetwork
  has_many :ip_addresses, dependent: :destroy

  accepts_nested_attributes_for :ip_addresses, allow_destroy: true
end
