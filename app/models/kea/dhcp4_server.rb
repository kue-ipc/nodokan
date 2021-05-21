module Kea
  class Dhcp4Server < KeaRecord
    self.table_name = 'dhcp4_server'

    has_many :dhcp4_subnet_servers, foreign_key: 'server_id',
      dependent: :destroy
    has_many :dhcp4_subnets, through: :dhcp4_subnet_servers

    def self.default
      find(1)
    end
  end
end
