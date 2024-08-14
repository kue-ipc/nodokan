module Kea
  class Host < KeaRecord
    # https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/host-reservation

    self.primary_key = "host_id"

    belongs_to :dhcp4_subnet, primary_key: "subnet_id", optional: true
    belongs_to :dhcp6_subnet, primary_key: "subnet_id", optional: true

    belongs_to :host_identifier_type, foreign_key: "dhcp_identifier_type",
      inverse_of: :hosts
    has_one :ipv6_reservation, dependent: :destroy

    def name
      dhcp_identifier.unpack("C*").map { |n| "%02X" % n }.join("-")
    end

    def ipv4
      ipv4_address && IPAddr.new(ipv4_address, Socket::AF_INET)
    end

    def ipv6
      ipv6_reservation&.ipv6
    end
  end
end
