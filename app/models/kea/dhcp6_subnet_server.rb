module Kea
  class Dhcp6SubnetServer < KeaRecord
    self.table_name = "dhcp6_subnet_server"
    self.primary_key = [:subnet_id, :server_id]

    belongs_to :dhcp6_server, foreign_key: "server_id",
      inverse_of: :dhcp6_subnet_server
    belongs_to :dhcp6_subnet, foreign_key: "subnet_id", primary_key: "subnet_id",
      inverse_of: :dhcp6_subnet_server
  end
end
