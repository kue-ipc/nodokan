class Ipv4Pool < ApplicationRecord
  include Ipv4Config
  include Enumerable

  belongs_to :network

  validates :ipv4_first_address, allow_blank: false, ip: true
  validates :ipv4_last_address, allow_blank: false, ip: true

  def ipv4_prefixlen
    network.ipv4_prefixlen
  end

  def ipv4_first
    @ipv4_first ||= IPAddress::IPv4.parse_data(ipv4_first_data, ipv4_prefixlen)
  end

  def ipv4_first_address
    @ipv4_first_address ||= ipv4_first.address
  end

  def ipv4_first_address=(value)
    @ipv4_first_address = value
    self.ipv4_first_data = @ipv4_first_address.presence &&
                         IPAddress::IPv4.new(@ipv4_first_address).data
  rescue ArgumentError
    self.ipv4_first_data = nil
  end

  def ipv4_last
    @ipv4_last ||= IPAddress::IPv4.parse_data(ipv4_last_data, ipv4_prefixlen)
  end

  def ipv4_last_address
    @ipv4_last_address ||= ipv4_last.address
  end

  def ipv4_last_address=(value)
    @ipv4_last_address = value
    self.ipv4_last_data = @ipv4_last_address.presence &&
                        IPAddress::IPv4.new(@ipv4_last_address).data
  rescue ArgumentError
    self.ipv4_last_data = nil
  end

  def ipv4_range
    @ipv4_range ||= Range.new(ipv4_first, ipv4_last)
  end

  def cover?(addr)
    ipv4_range.cover?(addr)
  end

  def each(&block)
    if block_given?
      ipv4_range.each(&block)
    else
      ipv4_range.each
    end
  end
end