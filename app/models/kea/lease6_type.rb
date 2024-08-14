module Kea
  class Lease6Type < KeaRecord
    self.primary_key = "lease_type"

    has_many :lease6s, foreign_key: "lease_type", inverse_of: :lease6_type
    has_many :lease6_stats, foreign_key: "lease_type", inverse_of: :lease6_type

    def readonly?
      true
    end
  end
end
