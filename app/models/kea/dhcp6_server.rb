module Kea
  class Dhcp6Server < KeaRecord
    self.table_name = "dhcp6_server"

    has_many :dhcp6_subnet_servers, foreign_key: "server_id",
      dependent: :destroy, inverse_of: :dhcp6_server
    has_many :dhcp6_subnets, through: :dhcp6_subnet_servers

    def self.default
      find(1)
    end
  end
end
