module Kea
  class Dhcp4SubnetServer < KeaRecord
    self.table_name = "dhcp4_subnet_server"
    self.primary_key = [:subnet_id, :server_id]

    belongs_to :dhcp4_server, foreign_key: "server_id",
      inverse_of: :dhcp4_subnet_servers
    belongs_to :dhcp4_subnet, foreign_key: "subnet_id", primary_key: "subnet_id",
      inverse_of: :dhcp4_subnet_servers
  end
end
