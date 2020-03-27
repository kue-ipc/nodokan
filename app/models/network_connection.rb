class NetworkConnection < ApplicationRecord
  belongs_to :network_interface
  belongs_to :subnetwork
end
