class OperatingSystem < ApplicationRecord
  has_many :nodes, dependent: :restrict_with_error

  enum category: {
    windows: 0,
    mac: 1,
    ios: 2,
    android: 3,
    linux: 4,
    bsd: 5,
    unix: 6,
    dedicated: 7,
    other: 255
  }
end
