module Kea
  class Dhcp4Subnet < KeaRecord
    self.table_name = 'dhcp4_subnet'
    self.primary_key = 'subnet_id'

    has_many :dhcp4_pools, foreign_key: 'subnet_id', primary_key: 'subnet_id',
      dependent: :destroy
    has_many :hosts, foreign_key: 'dhcp4_subnet_id', primary_key: 'subnet_id',
      dependent: :nullify
    has_many :dhcp4_subnet_servers,
      foreign_key: 'subnet_id', primary_key: 'subnet_id',
      dependent: :destroy
    has_many :dhcp4_servers, through: :dhcp4_subnet_servers
    end
end
