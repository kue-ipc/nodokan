class Bulk < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_one_attached :result
end
