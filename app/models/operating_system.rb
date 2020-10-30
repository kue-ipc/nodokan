class OperatingSystem < ApplicationRecord
  include OsCategory

  has_many :nodes, dependent: :restrict_with_error

  validates :os_category, presence: true

  validates :name, presence: true,
    length: {maximum: 255}, uniqueness: {case_sensitive: false}
end
