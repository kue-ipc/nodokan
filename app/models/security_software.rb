class SecuritySoftware < ApplicationRecord
  has_many :node, dependent: :restrict_with_error
end
