module Kea
  class Lease4 < KeaRecord
    self.table_name = 'lease4'
    self.primary_key = 'address'

    def ipv4
      @ipv4 ||= IPAddress::IPv4.parse_u32(address)
    end

    def ipv4_address
      ipv4.to_s
    end

    def name
      ipv4_address
    end
  end
end
