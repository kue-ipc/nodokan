module Kea
  class Lease4 < KeaRecord
    self.table_name = "lease4"
    self.primary_key = "address"

    belongs_to :lease_state, primary_key: "state", foreign_key: "state"
    belongs_to :dhcp4_subnet, primary_key: "subnet_id", foreign_key: "subnet_id"

    def ipv4
      IPAddr.new(address, Scoket::AF_INET)
    end

    def ipv4_address
      ipv4.to_s
    end

    def mac_address
      hwaddr.unpack("C6")
        .map { |i| format("%02X", i) }
        .join("-")
    end

    def name
      ipv4_address
    end

    def leased_at
      expire - valid_lifetime
    end
  end
end
