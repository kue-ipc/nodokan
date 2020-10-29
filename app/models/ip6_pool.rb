class Ip6Pool < ApplicationRecord
  include Ip6Config
  belongs_to :network

  def first
    @first ||= IPAddress::IPv6.new(@first6_address)
  end

  def last
    @last ||= IPAddress::IPv6.new(@last6_address)
  end

  def range
    @range ||= Range.new(first, last)
  end

  def include?(addr)
    addr = IPAddress::IPv6.new(addr.to_s) unless addr.is_a?(IPAddress::IPv6)
    range.cover?(addr)
  end
end
