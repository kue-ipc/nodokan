module Kea
  class LeaseState < KeaRecord
    self.table_name = "lease_state"
    self.primary_key = "state"

    has_many :lease4s, foreign_key: "state", inverse_of: :lease_state
    has_many :lease4_stats, foreign_key: "state", inverse_of: :lease_state
    has_many :lease6s, foreign_key: "state", inverse_of: :lease_state
    has_many :lease6_stats, foreign_key: "state", inverse_of: :lease_state

    def readonly?
      true
    end
  end
end
