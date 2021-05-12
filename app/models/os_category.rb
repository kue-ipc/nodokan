class OsCategory < ApplicationRecord
  has_many :operating_systems, dependent: :destroy
end
