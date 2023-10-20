module Kea
  class LeaseState < KeaRecord
    self.table_name = "lease_state"
    self.primary_key = "state"

    has_many :lease4s, primary_key: "state", foreign_key: "state"
    has_many :lease4_stats, primary_key: "state", foreign_key: "state"
    has_many :lease6s, primary_key: "state", foreign_key: "state"
    has_many :lease6_stats, primary_key: "state", foreign_key: "state"

    def readonly?
      true
    end
  end
end
