# scope_id は dhcp_option_scope で定義されている。
# subnet は 1 になる。

module Kea
  class Dhcp4Option < KeaRecord
    self.primary_key = 'option_id'

    belongs_to :dhcp4_subnet, primary_key: 'subnet_id', optional: true
    belongs_to :dhcp_option_scope,
      primary_key: 'scope_id', foreign_key: 'scope_id',
      inverse_of: :dhcp4_options
  end
end
