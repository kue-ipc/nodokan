class DeviceType < ApplicationRecord
  include Sanitizer
  include UniqueName

  has_paper_trail

  has_many :hardwares, dependent: :restrict_with_error

  validates :order, presence: true, numericality: {only_integer: true}

  normalizes :icon, with: ->(icon) {
    sanitize(icon, tags: %w[span i],
      attributes: %w[class style data-fa-transform]).strip
  }

  before_validation :auto_increment_order

  def auto_increment_order
    self.order ||= DeviceType.order(order: :desc).first&.order&.succ || 1
  end
end
