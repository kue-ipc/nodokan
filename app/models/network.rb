class Network < ApplicationRecord
  include IpConfig
  include Ip6Config

  def ip
    return if @ip_address.nil?

    @ip ||= IPAddress::IPv4.parse_data(@ip_address, @ip_prefix)
  end

  def gateway
    return if @ip_gateway.nil?

    @gateway ||= IPAddress::IPv4.parse_data(@ip_gateway)
  end

  def ip6
    return if @ip6_address.nil?

    @ip6 ||= IPAddress::IPv6.parse_data(@ip6_address, @ip6_prefix)
  end

  def gateway6
    return if @ip_gateway6.nil?

    @gateway6 ||= IPAddress::IPv6.parse_data(@ip6_gateway)
  end

end
