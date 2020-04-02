class NetworkInterface < ApplicationRecord
  belongs_to :node
  has_many :network_connections
  has_many :subnetworks, through: :network_connections

  enum interface: {
    wired: 0,
    wireless: 1,
    virtual: 2,
    bluetooth: 3,
    dialup: 4,
    loopback: 6,
    other: 7
  }

end
