module Kea
  class Host < KeaRecord
    self.primary_key = "host_id"

    belongs_to :dhcp4_subnet, primary_key: "subnet_id", optional: true
    belongs_to :dhcp6_subnet, primary_key: "subnet_id", optional: true
    belongs_to :host_identifier_type, foreign_key: "dhcp_identifier_type", primary_key: "identifier_type",
      inverse_of: :hosts

    has_one :ipv6_reservation, primary_key: "host_id", dependent: :destroy

    def name
      dhcp_identifier.unpack("C*").map { |n| "%02X" % n }.join("-")
    end

    def ipv4
      @ipv4 ||= ipv4_address && IPAddress::IPv4.parse_u32(ipv4_address)
    end
  end
end
