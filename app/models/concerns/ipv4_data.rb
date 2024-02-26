module Ipv4Data
  extend ActiveSupport::Concern

  included do
    validates :ipv4_address, allow_blank: true, ipv4_address: true
  end

  def ipv4
    ipv4_data && IPAddr.new_ntoh(ipv4_data)
  end

  def ipv4_address
    ipv4&.to_s
  end

  # value allow blank
  def ipv4_address=(value)
    self.ipv4_data = value.presence && IPAddr.new(value).hton
  end
end
