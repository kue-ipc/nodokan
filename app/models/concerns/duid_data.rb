module DuidData
  extend ActiveSupport::Concern
  include HexData

  included do
    validates :duid, allow_blank: true, duid: true
    after_validation :replace_duid_errors
  end

  def has_duid? # rubocop: disable Naming/PredicateName
    duid_data.present?
  end

  def duid_raw
    duid(char_case: :lower, sep: "")
  end

  def duid_list
    @duid_list ||= self.class.hex_data_to_list(duid_data)
  end

  def duid(**opts)
    self.class.hex_list_to_str(duid_list, **opts)
  end

  def duid=(value)
    @duid_list = nil
    self.duid_data = self.class.hex_str_to_data(value.presence)
  end

  private def replace_duid_errors
    errors[:duid_data].each do |msg|
      errors.add(:duid, msg)
    end
    errors.delete(:duid_data)
  end
end
