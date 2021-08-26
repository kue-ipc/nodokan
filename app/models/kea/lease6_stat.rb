module Kea
  class Lease6Stat < KeaRecord
    self.table_name = 'lease6_stat'
    self.primary_keys = 'subnet_id', 'lease_type', 'state'

    belongs_to :lease_state, primary_key: 'state', foreign_key: 'state'
    belongs_to :lease6_type, primary_key: 'lease_type'
    belongs_to :dhcp6_subnet, primary_key: 'subnet_id'
  end
end
