module Kea
  class Dhcp6Subnet < KeaRecord
    self.table_name = 'dhcp6_subnet'
    self.primary_key = 'subnet_id'
  end
end
