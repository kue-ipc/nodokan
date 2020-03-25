class Node < ApplicationRecord
  belongs_to :owner, polymorphic: true, optional: true
end
