module Kea
  class Lease4 < KeaRecord
    self.table_name = "lease4"
    self.primary_key = "address"

    belongs_to :dhcp4_subnet, foreign_key: "subnet_id", inverse_of: :lease4s,
      optional: true

    belongs_to :lease_state, foreign_key: "state", inverse_of: :lease4s,
      optional: true

    def ipv4
      IPAddr.new(address, Socket::AF_INET)
    end

    def ipv4_address
      ipv4.to_s
    end

    def mac_address
      hwaddr.unpack("C6").map { |i| "%02X" % i }.join("-")
    end

    def name
      ipv4_address
    end

    def leased_at
      expire - valid_lifetime
    end
  end
end
