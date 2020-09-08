class IpPool < ApplicationRecord
  include IpFamily
  include IpConfig

  belongs_to :ip_network
  has_many :ip_addresses, dependent: :nullify

  def first_address
    IPAddress(first)
  end

  def last_address
    IPAddress(last)
  end
end
