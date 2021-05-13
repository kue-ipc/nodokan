class DeviceType < ApplicationRecord
  has_many :hardwares, dependent: :restrict_with_error
end
