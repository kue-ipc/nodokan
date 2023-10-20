module Kea
  class LeaseHwaddrSource < KeaRecord
    self.table_name = "lease_hwaddr_source"
    self.primary_key = "hwaddr_source"

    has_many :lease6s, foreign_key: "hwaddr_source", primary_key: "hwaddr_source"

    def readonly?
      true
    end
  end
end
