class Place < ApplicationRecord
  has_many :nodes, as: :location, dependent: :nullify
end
