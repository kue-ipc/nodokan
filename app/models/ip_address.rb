class IpAddress < ApplicationRecord
  include IpConfig

  belongs_to :network_connection
end
