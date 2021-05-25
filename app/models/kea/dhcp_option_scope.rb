# scope_id は dhcp_option_scope で定義されている。
# subnet は 1 になる。

module Kea
  class DhcpOptionScope < KeaRecord
    self.primary_key = "scope_id"
    self.table_name = "dhcp_option_scope"

    has_many :dhcp4_options,
      primary_key: "scope_id", foreign_key: "scope_id",
      dependent: :restrict_with_exception, inverse_of: :dhcp_option_scope
    has_many :dhcp6_options,
      primary_key: "scope_id", foreign_key: "scope_id",
      dependent: :restrict_with_exception, inverse_of: :dhcp_option_scope

    def name
      scope_name
    end

    def to_s
      scope_name
    end

    def readonly?
      true
    end
  end
end
