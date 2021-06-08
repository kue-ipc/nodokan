class DeviceType < ApplicationRecord
  has_many :hardwares, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 255 },
    uniqueness: { case_sensitive: false }
  validates :order, presence: :true, numericality: { only_integer: true }

  normalize_attribute :name
  normalize_attribute :icon, with: [:strip, :blank, :sanitize]
  normalize_attribute :description

  before_validation :auto_increment_order

  def auto_increment_order
    self.order = DeviceType.order(order: :desc).first&.order&.succ || 1 if order.nil? || order.zero?
  end
end
