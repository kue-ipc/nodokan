class IpPool < ApplicationRecord
  include IpConfig
  include Enumerable

  belongs_to :network

  validates :ip_first_address, allow_blank: false, ip: true
  validates :ip_last_address, allow_blank: false, ip: true

  def ip_prefixlen
    network.ip_prefixlen
  end

  def ip_first
    @ip_first ||= IPAddress::IPv4.parse_data(ip_first_data, ip_prefixlen)
  end

  def ip_first_address
    @ip_first_address ||= ip_first.address
  end

  def ip_first_address=(value)
    @ip_first_address = value
    self.ip_first_data = @ip_first_address.presence &&
                         IPAddress::IPv4.new(@ip_first_address).data
  rescue ArgumentError
    self.ip_first_data = nil
  end

  def ip_last
    @ip_last ||= IPAddress::IPv4.parse_data(ip_last_data, ip_prefixlen)
  end

  def ip_last_address
    @ip_last_address ||= ip_last.address
  end

  def ip_last_address=(value)
    @ip_last_address = value
    self.ip_last_data = @ip_last_address.presence &&
                        IPAddress::IPv4.new(@ip_last_address).data
  rescue ArgumentError
    self.ip_last_data = nil
  end

  def ip_range
    @ip_range ||= Range.new(ip_first, ip_last)
  end

  def cover?(addr)
    ip_range.cover?(addr)
  end

  def each(&block)
    if block_given?
      ip_range.each(&block)
    else
      ip_range.each
    end
  end
end
