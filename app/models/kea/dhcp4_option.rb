# scope_id は dhcp_option_scope で定義されている。
# subnet は 1 になる。

module Kea
  class Dhcp4Option < KeaRecord
    self.primary_key = 'option_id'

    belongs_to :dhcp4_subnet, primary_key: 'subnet_id', optional: true
  end
end
