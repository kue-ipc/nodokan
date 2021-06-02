class Hardware < ApplicationRecord
  belongs_to :device_type, optional: true

  has_many :node, dependent: :restrict_with_error

  def name
    [maker, product_name].select(&:present?).join(' ')
  end

  def device_type_name
    @device_type_name ||= device_type&.name
  end

  def device_type_name=(str)
    if str.present?
      self.device_type = DeviceType.find_by!(name: str)
      @device_type_name = device_type&.name
    else
      self.device_type = nil
      @device_type_name = nil
    end
  end

  def icon
    device_type&.icon
  end

  def locked
    device_type&.locked
  end
end
