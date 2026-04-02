class OsCategory < ApplicationRecord
  include Sanitizer
  include Unique

  has_paper_trail

  unique :name, normalize: :squish

  has_many :operating_systems, dependent: :restrict_with_error
  has_many :security_softwares, dependent: :restrict_with_error

  validates :order, presence: true, numericality: {only_integer: true}

  normalizes :icon, with: ->(icon) {
    sanitize(icon, tags: %w[span i],
      attributes: %w[class style data-fa-transform]).strip
  }

  before_validation :auto_increment_order

  def auto_increment_order
    self.order ||= OsCategory.order(order: :desc).first&.order&.succ || 1
  end
end
