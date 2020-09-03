class IpPool < ApplicationRecord
  include IpFamily

  include IpConfig

  belongs_to :subnetwork

  def first_address
    IPAddress(first)
  end

  def last_address
    IPAddress(last)
  end
end
