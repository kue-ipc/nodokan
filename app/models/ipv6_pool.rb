class Ipv6Pool < ApplicationRecord
  include Ipv6Config
  belongs_to :network

  validates :ipv6_first_address, allow_blank: false, ipv6: true
  validates :ipv6_last_address, allow_blank: false, ipv6: true

  def ipv6_prefixlen
    network.ipv6_prefixlen
  end

  def ipv6_first
    @ipv6_first ||= IPAddress::IPv6.parse_data(ipv6_first_data, ipv6_prefixlen)
  end

  def ipv6_first_address
    @ipv6_first_address ||= ipv6_first.address
  end

  def ipv6_first_address=(value)
    @ipv6_first_address = value
    self.ipv6_first_data = @ipv6_first_address.presence &&
                         IPAddress::IPv6.new(@ipv6_first_address).data
  rescue ArgumentError
    self.ipv6_first_data = nil
  end

  def ipv6_last
    @ipv6_last ||= IPAddress::IPv6.parse_data(ipv6_last_data, ipv6_prefixlen)
  end

  def ipv6_last_address
    @ipv6_last_address ||= ipv6_last.address
  end

  def ipv6_last_address=(value)
    @ipv6_last_address = value
    self.ipv6_last_data = @ipv6_last_address.presence &&
                        IPAddress::IPv6.new(@ipv6_last_address).data
  rescue ArgumentError
    self.ipv6_last_data = nil
  end

  def ipv6_range
    @ipv6_range ||= Range.new(ipv6_first, ipv6_last)
  end

  def include?(addr)
    addr = IPAddress::IPv6.new(addr.to_s) unless addr.is_a?(IPAddress::IPv6)
    ipv6_range.cover?(addr)
  end
end
