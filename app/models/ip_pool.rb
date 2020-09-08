class IpPool < ApplicationRecord
  include IpFamily
  include IpConfig

  belongs_to :ip_network
  has_many :ip_addresses, dependent: :nullify

  def first_address
    @first_address ||= IPAddress(first)
  end

  def last_address
    @last_address ||= IPAddress(last)
  end

  def size
    @size ||= (last_address - first_address + 1)
  end
end
