class IpNetwork < ApplicationRecord
  belongs_to :subnetwork

  enum ip_version: {
    ipv4: 4,
    ipv6: 6,
  }
end
