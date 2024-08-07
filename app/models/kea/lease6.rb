module Kea
  class Lease6 < KeaRecord
    # address NOT NULL PRIMARY KEY
    #   schema_version < 19.0 VARCHAR(39)
    #   scheam_version >= 19.0 BINARY(16)

    self.table_name = "lease6"
    self.primary_key = "address"

    belongs_to :lease_hwaddr_source, primary_key: "hwaddr_source",
      foreign_key: "hwaddr_source"
    belongs_to :lease_state, primary_key: "state", foreign_key: "state"
    belongs_to :lease6_types, primary_key: "lease_type",
      foreign_key: "foreign_key"
    belongs_to :dhcp6_subnet, primary_key: "subnet_id", foreign_key: "subnet_id"

    def ipv6
      if Kea::Lease6.schema_major_version >= 19
        IPAddr.new_ntoh(address)
      else
        IPaddr.new(address)
      end
    end

    def ipv6_address
      ipv6.to_s
    end

    def duid_str
      duid.unpack("C*").map { |i| "%02X" % i }.join("-")
    end

    def name
      ipv6_address
    end

    def leased_at
      expire - valid_lifetime
    end

    # FIXME: rails_adminで見えるようにするために設定
    #   他に影響があるかは不明
    def id
      ipv6.to_i
    end
  end
end
