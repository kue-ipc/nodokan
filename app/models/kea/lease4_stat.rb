module Kea
  class Lease4Stat < KeaRecord
    self.table_name = "lease4_stat"
    self.primary_keys = "subnet_id", "state"

    belongs_to :lease_state, primary_key: "state", foreign_key: "state"
    belongs_to :dhcp4_subnet, primary_key: "subnet_id", foreign_key: "subnet_id"
  end
end
