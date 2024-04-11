module Ipv6Data
  extend ActiveSupport::Concern

  included do
    validates :ipv6_address, allow_blank: true, ipv6_address: true
  end

  # ipv6 ... IPAddr allow nil
  # ipv6_address ... String allow blank

  def has_ipv6?
    ipv6_data.present?
  end

  def ipv6
    ipv6_data && IPAddr.new_ntoh(ipv6_data)
  end

  def ipv6_address
    ipv6&.to_s
  end

  def ipv6=(value)
    self.ipv6_data = value&.hton
  end

  def ipv6_address=(value)
    self.ipv6 = value.presence && IPAddr.new(value)
  end
end
