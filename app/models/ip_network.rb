class IpNetwork < ApplicationRecord
  include IpFamily

  belongs_to :subnetwork
  has_many :ip_pool, dependent: :destroy

  def ip_address
    IPAddress(address)
  end
end
