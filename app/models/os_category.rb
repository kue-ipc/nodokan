class OsCategory < ApplicationRecord
  has_many :operating_systems, dependent: :restrict_with_error
  has_many :security_softwares, dependent: :restrict_with_error
end
