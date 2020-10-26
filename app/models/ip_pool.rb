class IpPool < ApplicationRecord
  include IpConfig
  belongs_to :network

  def first
    @first ||= IPAddress::IPv4.new(@first_address)
  end

  def last
    @last ||= IPAddress::IPv4.new(@last_address)
  end

  def include?(addr)
    addr = IPAddress::IPv4.new(addr.to_s) unless addr.is_a?(IPAddress::IPv4)
    first <= addr && addr <= last
  end
end
