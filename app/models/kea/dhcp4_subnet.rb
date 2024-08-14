module Kea
  class Dhcp4Subnet < KeaRecord
    self.table_name = "dhcp4_subnet"
    self.primary_key = "subnet_id"

    has_many :dhcp4_pools, foreign_key: "subnet_id", inverse_of: :dhcp4_subnet,
      dependent: :destroy

    has_many :hosts, dependent: :nullify

    has_many :dhcp4_options, dependent: :destroy

    has_and_belongs_to_many :dhcp4_servers, join_table: "dhcp4_subnet_server",
      foreign_key: "subnet_id", association_foreign_key: "server_id"

    def name
      subnet_prefix
    end

    def ipv4
      IPAddr.new(subnet_prefix)
    end
  end
end
