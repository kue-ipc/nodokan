module Kea
  class Lease6 < KeaRecord
    self.table_name = "lease6"
    self.primary_key = "address"

    belongs_to :lease_hwaddr_source, primary_key: "hwaddr_source",
      foreign_key: "hwaddr_source"
    belongs_to :lease_state, primary_key: "state", foreign_key: "state"
    belongs_to :lease6_types, primary_key: "lease_type",
      foreign_key: "foreign_key"
    belongs_to :dhcp6_subnet, primary_key: "subnet_id", foreign_key: "subnet_id"

    def ipv6
      IPAddr.new(address)
    end

    def ipv6_address
      address
    end

    def duid_str
      duid.unpack("C*")
        .map { |i| "%02X" % i }
        .join("-")
    end

    def name
      ipv6_address
    end

    def leased_at
      expire - valid_lifetime
    end
  end
end
