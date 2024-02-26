module Ipv6Data
  extend ActiveSupport::Concern

  included do
    validates :ipv6_address, allow_blank: true, ipv6_address: true
  end

  def ipv6
    ipv6_data && IPAddr.new_ntoh(ipv6_data)
  end

  def ipv6_address
    ipv6&.to_s
  end

  # value allow blank
  def ipv6_address=(value)
    self.ipv6_data = value.presence && IPAddr.new(value).hton
  end
end
