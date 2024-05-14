module Kea
  class Dhcp6Pool < KeaRecord
    self.table_name = "dhcp6_pool"

    belongs_to :dhcp6_subnet, foreign_key: "subnet_id",
      primary_key: "subnet_id", inverse_of: :dhcp6_pools

    def start_ipv6
      IPAddr.new(start_address)
    end

    def end_ipv6
      IPAddr.new(end_address)
    end

    def name
      "#{start_address}-#{end_address}"
    end
  end
end
