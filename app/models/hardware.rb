class Hardware < ApplicationRecord
  belongs_to :device_type, optional: true

  has_many :node, dependent: :restrict_with_error

  enum device_type: {
    desktop: 0,
    laptop: 1,
    tablet: 2,
    mobile: 3,
    peripheral: 8,
    server: 16,
    appliance: 17,
    network: 32,
    virtual: 128,
    other: 255,
    unknown: -1,
  }

  def name
    [maker, product_name].select(&:present?).join(' ')
  end

  def device_type_name
    @device_type_name ||= device_type&.name
  end

  def device_type_name=(str)
    if str.present?
      self.device_type = DeviceType.find(name: str)
      @device_type_name = device_type&.name
    else
      self.device_type = nil
      @device_type_name = nil
    end
  end

  def icon
    device_type&.icon
  end
end
