class Ipv4Arp < ApplicationRecord
  include Ipv4Data
  include MacAddressData

  validates :ipv4_data, length: {is: 4}
  validates :mac_address_data, length: {is: 6}
  validates :resolved_at, presence: true

  alias_attribute :resolved_at, :end_at

  before_save :set_begin_at_if_null

  def set_begin_at_if_null
    return if begin_at

    # アップデートされているときは、以前の値を優先して設定する
    self.begin_at = end_at_was || end_at
  end

  def name
    "#{ipv4_address} #{mac_address}"
  end

  def range
    if begin_at
      (begin_at..end_at)
    else
      (end_at..end_at)
    end
  end
end
