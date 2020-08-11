class NetworkInterface < ApplicationRecord
  belongs_to :node
  has_many :network_connections
  has_many :subnetworks, through: :network_connections

  enum interface_type: {
    wired: 0,
    wireless: 1,
    virtual: 2,
    bluetooth: 3,
    dialup: 4,
    vpn: 5,
    other: 255
  }

end
