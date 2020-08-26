class IpPool < ApplicationRecord
  include IpConfig

  belongs_to :subnetwork
end
