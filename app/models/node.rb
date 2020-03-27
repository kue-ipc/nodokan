class Node < ApplicationRecord
  belongs_to :owner, polymorphic: true, optional: true
  belongs_to :location, polymorphic: true, optional: true
  has_many :nodes, as: :location, dependent: :nullify
end
