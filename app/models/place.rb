class Place < ApplicationRecord
  has_many :nodes, dependent: :restrict_with_error
end
