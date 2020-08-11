class IpAddress < ApplicationRecord
  belongs_to :network_connection

  enum config: {
    manual: 0,
    auto: 1,
    reserved: 2,
  }
end
