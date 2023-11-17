module Ipv4Data
  extend ActiveSupport::Concern

  def ipv4
    @ipv4 ||= ipv4_data.presence && IPAddress::IPv4.parse_data(ipv4_data)
  end

  def ipv4_global?
    !(ipv4.nil? || ipv4.private?)
  end

  def ipv4_address
    @ipv4_address ||= (ipv4&.to_s || "")
  end

  def ipv4_address=(value)
    @ipv4_address = value
    @ipv4 = @ipv4_address.presence && IPAddress::IPv4.new(@ipv4_address)
    self.ipv4_data = @ipv4&.data
  rescue ArgumentError
    @ipv4_address = ""
    @ipv4 = nil
    self.ipv4_data = nil
  end
end
