class Hardware < ApplicationRecord
  has_many :node, dependent: :restrict_with_error

  enum device_type: {
    desktop: 0,
    laptop: 1,
    tablet: 2,
    mobile: 3,
    server: 4,
    appliance: 5,
    network: 16,
    virtual: 128,
    other: 255,
    unknown: -1,
  }

  validates :device_type, presence: true

  def name
    [maker, product_name].select(&:present?).join(' ')
  end
end
