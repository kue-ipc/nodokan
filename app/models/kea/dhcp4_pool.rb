module Kea
  class Dhcp4Pool < KeaRecord
    self.table_name = "dhcp4_pool"

    belongs_to :dhcp4_subnet, foreign_key: "subnet_id",
      primary_key: "subnet_id", inverse_of: :dhcp4_pools

    def start_ipv4
      IPAddr.new(start_address, Socket::AF_INET)
    end

    def end_ipv4
      IPAddr.new(end_address, Socket::AF_INET)
    end

    def name
      "#{start_ipv4}-#{end_ipv4}"
    end
  end
end
