module Kea
  class Dhcp6Option < KeaRecord
    self.primary_key = "option_id"

    belongs_to :dhcp6_subnet, primary_key: "subnet_id", optional: true
    belongs_to :dhcp_option_scope, primary_key: "scope_id",
      foreign_key: "scope_id", inverse_of: :dhcp6_options
  end
end
