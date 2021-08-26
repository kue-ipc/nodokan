module Kea
  class Lease4 < KeaRecord
    self.table_name = 'lease4'
    self.primary_key = 'address'

    belongs_to :lease_state, primary_key: 'state', foreign_key: 'state'
    belongs_to :dhcp4_subnet, primary_key: 'subnet_id', foreign_key: 'subnet_id'

    def ipv4
      @ipv4 ||= IPAddress::IPv4.parse_u32(address)
    end

    def name
      ipv4_address
    end
  end
end
