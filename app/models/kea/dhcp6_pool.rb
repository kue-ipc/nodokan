module Kea
  class Dhcp6Pool < KeaRecord
    self.table_name = "dhcp6_pool"

    belongs_to :dhcp6_subnet, foreign_key: "subnet_id", primary_key: "subnet_id",
      inverse_of: :dhcp6_pool
  end
end
