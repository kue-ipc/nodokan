class Hardware < ApplicationRecord
  has_many :node, dependent: :restrict_with_error

  enum category: {
    desktop: 0,
    laptop: 1,
    tablet: 2,
    mobile: 3,
    server: 4,
    network: 5,
    virtual: 6,
    other: 255,
    unknown: -1,
  }
end
