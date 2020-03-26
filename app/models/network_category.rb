class NetworkCategory < ApplicationRecord
  has_many :subnetworks, dependent: :restrict_with_error
end
