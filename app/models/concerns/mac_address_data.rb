# mac_address_data attributes
#   raw attribute: mac_address_data
#   value attribute: mac_address
module MacAddressData
  extend ActiveSupport::Concern
  include HexData
  include ReplaceError

  included do
    validates :mac_address, allow_blank: true, mac_address: true
    after_validation :replace_mac_address_errors
  end

  def has_mac_address? # rubocop: disable Naming/PredicateName
    mac_address_data.present?
  end

  def mac_address_gl
    !((mac_address_list.first || 0) & 0x02).zero?
  end

  def mac_address_ig
    !((mac_address_list.first || 0) & 0x01).zero?
  end

  def mac_address_global?
    !mac_address_gl
  end

  def mac_address_local?
    mac_address_gl
  end

  def mac_address_unicast?
    !mac_address_ig
  end

  def mac_address_multicast?
    mac_address_ig
  end

  def mac_address_list
    @mac_address_list ||= self.class.hex_data_to_list(mac_address_data)
  end

  def mac_address_raw
    mac_address(char_case: :lower, sep: "")
  end

  def mac_address(**opts)
    self.class.hex_list_to_str(mac_address_list, **opts)
  end

  def mac_address=(value)
    @mac_address_list = nil
    self.mac_address_data = self.class.hex_str_to_data(value.presence)
  end

  def modified_eui64_list
    mac_address_list && [
      mac_address_list[0] ^ 2,
      *mac_address_list[1..2],
      0xff, 0xfe,
      *mac_address_list[3..5],
    ]
  end

  def modified_eui64(**opts)
    self.class.hex_list_to_str(modified_eui64_list, **opts)
  end

  private def replace_mac_address_errors
    replace_error(:mac_address_data, :mac_address)
  end
end
