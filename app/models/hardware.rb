class Hardware < ApplicationRecord
  belongs_to :device_type, optional: true

  has_many :nodes, dependent: :restrict_with_error

  validates :maker, length: {maximum: 255}
  validates :product_name, length: {maximum: 255}
  validates :model_number, length: {maximum: 255}, uniqueness: {
    scope: [:device_type_id, :maker, :product_name],
    case_sensitive: true,
  }

  def name
    [maker, product_name].select(&:present?).join(" ")
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

  def same
    Hardware.where.not(id: id).find_by(
      device_type_id: device_type_id,
      maker: maker,
      product_name: product_name,
      model_number: model_number,
    )
  end
end
