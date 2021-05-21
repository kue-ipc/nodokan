module Kea
  class Dhcp4SubnetServer < KeaRecord
    self.table_name = 'dhcp4_subnet_server'
    self.primary_keys = 'subnet_id', 'server_id'

    belongs_to :dhcp4_server, foreign_key: 'server_id'
    belongs_to :dhcp4_subnet, foreign_key: 'subnet_id', primary_key: 'subnet_id'
    # has_many :dhcp4_subnet_servers, dependent: :destroy
    # has_many :dhcp4_subnets, through: :dhcp4_subnet_servers

    # :dhcp4_pools, foreign_key: 'subnet_id', primary_key: 'subnet_id',
    #   dependent: :destroy
    # has_many :hosts, foreign_key: 'dhcp4_subnet_id', primary_key: 'subnet_id',
    #   dependent: :nullify
  end
end
