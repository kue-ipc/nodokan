module Kea
  class Dhcp4Server < KeaRecord
    self.table_name = 'dhcp4_server'

    has_many :dhcp4_subnet_servers, dependent: :destroy
    has_many :dhcp4_subnets, through: :dhcp4_subnet_servers


    # :dhcp4_pools, foreign_key: 'subnet_id', primary_key: 'subnet_id',
    #   dependent: :destroy
    # has_many :hosts, foreign_key: 'dhcp4_subnet_id', primary_key: 'subnet_id',
    #   dependent: :nullify
  end
end
