module Kea
  class Dhcp4Subnet < KeaRecord
    self.table_name = 'dhcp4_subnet'
    self.primary_key = 'subnet_id'

    has_many :dhcp4_pools,
      foreign_key: 'subnet_id', primary_key: 'subnet_id',
      dependent: :destroy, inverse_of: :dhcp4_subnet
    has_many :hosts,
      primary_key: 'subnet_id',
      dependent: :nullify, inverse_of: :dhcp4_subnet
    has_many :dhcp4_subnet_servers,
      foreign_key: 'subnet_id', primary_key: 'subnet_id',
      dependent: :destroy, inverse_of: :dhcp4_subnet

    # subnetはscope_idが1
    has_many :dhcp4_options,
      -> { where(scope_id: 1) },
      primary_key: 'subnet_id',
      dependent: :destroy, inverse_of: :dhcp4_subnet

    has_many :dhcp4_servers,
      through: :dhcp4_subnet_servers
  end
end
