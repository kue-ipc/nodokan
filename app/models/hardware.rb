class Hardware < ApplicationRecord
  has_paper_trail

  belongs_to :device_type, optional: true

  has_many :nodes, dependent: :restrict_with_error

  validates :device_type, presence: true, if: :device_type_id?
  validates :maker, length: {maximum: 255}
  validates :product_name, length: {maximum: 255}
  validates :model_number, length: {maximum: 255}, uniqueness: {
    scope: [:device_type_id, :maker, :product_name],
    case_sensitive: true,
  }

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w(device_type_id maker product_name model_number confirmed nodes_count)
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
  # rubocop: enable Lint/UnusedMethodArgument

  def name
    [maker, product_name].compact_blank.join(" ")
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
    Hardware.where.not(id:).find_by(device_type_id:, maker:, product_name:,
      model_number:)
  end
end
