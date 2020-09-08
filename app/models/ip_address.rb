class IpAddress < ApplicationRecord
  include IpConfig
  include IpFamily

  belongs_to :network_connection
  belongs_to :ip_pool

  def ip_address
    @ip_address ||= IPAddress(address)
  end
end
