module Kea
  class Lease4Stat < KeaRecord
    self.table_name = "lease4_stat"
    self.primary_key = [:subnet_id, :state]

    belongs_to :dhcp4_subnet, foreign_key: "subnet_id",
      inverse_of: :lease4_stats

    belongs_to :lease_state, foreign_key: "state", inverse_of: :lease4_stats
  end
end
