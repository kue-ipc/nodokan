class IpAddress < ApplicationRecord
  belongs_to :network_connection

  enum ip_version: {
    ipv4: 4,
    ipv6: 6,
  }

  enum config: {
    static: 0,
    dhcp: 1,
    reserved: 2,
  }
end
