module Kea
  class Dhcp6Subnet < KeaRecord
    self.table_name = "dhcp6_subnet"
    self.primary_key = "subnet_id"

    has_many :dhcp6_options, dependent: :destroy
    has_many :dhcp6_pools, foreign_key: "subnet_id", inverse_of: :dhcp6_subnet,
      dependent: :destroy
    has_and_belongs_to_many :dhcp6_servers, join_table: "dhcp6_subnet_server",
      foreign_key: "subnet_id", association_foreign_key: "server_id"

    has_many :hosts, dependent: :nullify

    has_many :lease6s, foreign_key: "subnet_id", inverse_of: :dhcp6_subnet,
      dependent: :nullify
    has_many :lease6_stats, foreign_key: "subnet_id", inverse_of: :dhcp6_subnet,
      dependent: :delete_all

    def name
      subnet_prefix
    end

    def ipv6
      IPAddr.new(subnet_prefix)
    end
  end
end
