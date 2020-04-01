class Node < ApplicationRecord
  belongs_to :owner, polymorphic: true, optional: true
  belongs_to :location, polymorphic: true, optional: true
  has_many :nodes, as: :location, dependent: :nullify

  belongs_to :hardware, optional: true
  belongs_to :operating_system, optional: true
  belongs_to :security_software, optional: true

  has_many :network_interfaces
end
