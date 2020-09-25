class Ip6Pool < ApplicationRecord
  include Ip6Config
  belongs_to :network

  def first6
    @first6 ||= IPAddress::IPv6.parse_data(@first6_address)
  end

  def last6
    @last6 ||= IPAddress::IPv6.parse_data(@last6_address)
  end
end
