module Ipv6Data
  extend ActiveSupport::Concern

  def ipv6
    @ipv6 ||= ipv6_data.presence && IPAddress::IPv6.parse_hex(ipv6_data.unpack1("H*"))
  end

  def ipv6_global?
    !(ipv6.nil? || ipv6.unique_local?)
  end

  def ipv6_address
    @ipv6_address ||= (ipv6&.to_s || "")
  end

  def ipv6_address=(value)
    @ipv6_address = value
    @ipv6 = @ipv6_address.presence && IPAddress::IPv6.new(@ipv6_address)
    self.ipv6_data = @ipv6&.data
  rescue ArgumentError
    @ipv6_address = ""
    @ipv6 = nil
    self.ipv6_data = nil
  end
end
