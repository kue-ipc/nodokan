module Ipv4Data
  extend ActiveSupport::Concern

  included do
    validates :ipv4_address, allow_blank: true, ipv4_address: true
    after_validation :replace_ipv4_errors
  end

  # ipv4 ... IPAddr allow nil
  # ipv4_address ... String allow blank

  def has_ipv4? # rubocop: disable Naming/PredicateName
    ipv4_data.present?
  end

  def ipv4
    ipv4_data && IPAddr.new_ntoh(ipv4_data)
  end

  def ipv4_address
    ipv4&.to_s
  end

  def ipv4=(value)
    self.ipv4_data = value&.hton
  end

  def ipv4_address=(value)
    self.ipv4 = value.presence && IPAddr.new(value)
  end

  private def replace_ipv4_errors
    errors[:ipv4_data].each do |msg|
      errors.add(:ipv4_address, msg)
    end
    errors.delete(:ipv4_data)
  end
end
