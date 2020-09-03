class IpNetwork < ApplicationRecord
  include IpFamily

  belongs_to :subnetwork

  def ip_address
    IPAddress(address)
  end
end
