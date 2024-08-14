module Kea
  class Lease6Stat < KeaRecord
    self.table_name = "lease6_stat"
    self.primary_key = [:subnet_id, :lease_type, :state]

    belongs_to :dhcp6_subnet, foreign_key: "subnet_id",
      inverse_of: :lease6_stats

    belongs_to :lease_state, foreign_key: "state", inverse_of: :lease6_stats
    belongs_to :lease6_type, foreign_key: "lease_type",
      inverse_of: :lease6_stats
  end
end
