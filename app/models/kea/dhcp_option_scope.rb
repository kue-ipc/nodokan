module Kea
  class DhcpOptionScope < KeaRecord
    self.primary_key = "scope_id"
    self.table_name = "dhcp_option_scope"

    has_many :dhcp4_options, foreign_key: "scope_id",
      inverse_of: :dhcp_option_scope, dependent: :restrict_with_exception
    has_many :dhcp6_options, foreign_key: "scope_id",
      inverse_of: :dhcp_option_scope, dependent: :restrict_with_exception

    def readonly?
      true
    end

    def name
      scope_name
    end

    def self.global
      find_by(scope_name: "global")
    end

    def self.subnet
      find_by(scope_name: "subnet")
    end
  end
end
