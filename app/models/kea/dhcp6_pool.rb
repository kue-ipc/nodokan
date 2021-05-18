module Kea
  class Dhcp6Pool < KeaRecord
    self.table_name = 'dhcp6_pool'

    belongs_to :subnet, class_name: 'Dhcp6Subnet', primary_key: 'subnet_id'
  end
end
