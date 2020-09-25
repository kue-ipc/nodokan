class IpPool < ApplicationRecord
  include IpConfig
  belongs_to :network

  def first
    @first ||= IPAddress::IPv4.parse_data(@first_address)
  end

  def last
    @last ||= IPAddress::IPv4.parse_data(@last_address)
  end
end
