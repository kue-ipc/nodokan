module Kea
  class Dhcp6Server < KeaRecord
    self.table_name = "dhcp6_server"

    has_and_belongs_to_many :dhcp6_options, join_table: "dhcp6_options_server",
      foreign_key: "server_id", association_foreign_key: "option_id"
    has_and_belongs_to_many :dhcp6_subnets, join_table: "dhcp6_subnet_server",
      foreign_key: "server_id", association_foreign_key: "subnet_id"

    def name
      tag
    end

    def self.default
      find(1)
    end
  end
end
