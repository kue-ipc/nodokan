module Kea
  class Dhcp4Server < KeaRecord
    self.table_name = "dhcp4_server"

    has_and_belongs_to_many :dhcp4_options, join_table: "dhcp4_options_server",
      foreign_key: "server_id", association_foreign_key: "option_id"
    has_and_belongs_to_many :dhcp4_subnets, join_table: "dhcp4_subnet_server",
      foreign_key: "server_id", association_foreign_key: "subnet_id"

    def name
      tag
    end

    def self.default
      find(1)
    end
  end
end
