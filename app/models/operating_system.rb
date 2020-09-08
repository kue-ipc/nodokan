class OperatingSystem < ApplicationRecord
  include OsCategory

  has_many :nodes, dependent: :restrict_with_error
end
