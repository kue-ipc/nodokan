class IpAddress < ApplicationRecord
  include IpConfig
  include IpFamily

  belongs_to :network_connection

  def ip_address
    IPAddress(address)
  end
end
