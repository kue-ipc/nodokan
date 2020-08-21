class Node < ApplicationRecord
  belongs_to :user

  belongs_to :place, optional: true, counter_cache: true
  belongs_to :hardware, optional: true, counter_cache: true
  belongs_to :operating_system, optional: true, counter_cache: true
  belongs_to :security_software, optional: true, counter_cache: true

  has_many :network_interfaces, dependent: :destroy
  accepts_nested_attributes_for :network_interfaces, allow_destroy: true
end
