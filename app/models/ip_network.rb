class IpNetwork < ApplicationRecord
  include IpFamily

  belongs_to :subnetwork
  has_many :ip_pools, dependent: :destroy

  def ip_address
    @ip_address ||= IPAddress(address)
  end
end
