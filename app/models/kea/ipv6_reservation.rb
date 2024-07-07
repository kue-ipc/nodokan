module Kea
  class Ipv6Reservation < KeaRecord
    # https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/host-reservation
    # address NOT NULL
    #   schema_version < 19.0 VARCHAR(39)
    #   scheam_version >= 19.0 BINARY(16)

    # ipv6_reservations_alt view in type as reservation_type
    self.table_name = "ipv6_reservations_alt"
    self.primary_key = "reservation_id"

    # type: Type of the reservation. A value of 0 is IPv6 address reservation, a value of 2 is IPv6 prefix reservation.
    enum reservation_type: {
      address: 0,
      prefix: 2,
    }, _prefix: :type

    belongs_to :host, primary_key: "host_id"

    def ipv6
      if Ipv6Reservation.schema_major_version >= 19
        IPAddr.new_ntoh(address)
      else
        IPAddr.new(address)
      end
    end
  end
end
