module Kea
  class Dhcp4Pool < KeaRecord
    self.table_name = 'dhcp4_pool'

    belongs_to :dhcp4_subnet, foreign_key: 'subnet_id', primary_key: 'subnet_id',
      inverse_of: :dhcp4_pools
  end
end
