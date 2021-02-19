class Ip6Pool < ApplicationRecord
  include Ip6Config
  belongs_to :network

  validates :ip6_first_address, allow_blank: false, ip: true
  validates :ip6_last_address, allow_blank: false, ip: true

  def ip6_first
    @ip6_first ||= IPAddress::IPv6.parse_data(ip6_first_data)
  end

  def ip6_first_address
    @ip6_first_address ||= @ip6_first.address
  end

  def ip6_first_address=(value)
    @ip6_first_address = value
    self.ip6_first_data = @ip6_first_address.presence &&
                         IPAddress::IPv6.new(@ip6_first_address).data
  rescue ArgumentError
    self.ip6_first_data = nil
  end

  def ip6_last
    @ip6_last ||= IPAddress::IPv6.parse_data(ip6_last_data)
  end

  def ip6_last_address
    @ip6_last_address ||= @ip6_last.address
  end

  def ip6_last_address=(value)
    @ip6_last_address = value
    self.ip6_last_data = @ip6_last_address.presence &&
                        IPAddress::IPv6.new(@ip6_last_address).data
  rescue ArgumentError
    self.ip6_last_data = nil
  end

  def ip6_range
    @ip6_range ||= Range.new(ip6_first, ip6_last)
  end

  def include?(addr)
    addr = IPAddress::IPv6.new(addr.to_s) unless addr.is_a?(IPAddress::IPv6)
    ip6_range.cover?(addr)
  end
end
