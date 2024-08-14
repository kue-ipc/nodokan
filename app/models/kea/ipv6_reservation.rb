module Kea
  class Ipv6Reservation < KeaRecord
    # https://gitlab.isc.org/isc-projects/kea/-/wikis/designs/host-reservation
    # address NOT NULL
    #   schema_version < 19.0 VARCHAR(39)
    #   scheam_version >= 19.0 BINARY(16)

    # type attribute is not an inheritence column
    self.inheritance_column = "inheritance_type"
    self.primary_key = "reservation_id"

    # type: Type of the reservation. A value of 0 is IPv6 address reservation, a value of 2 is IPv6 prefix reservation.
    enum :type, {
      address: 0,
      prefix: 2,
    }, prefix: :type

    belongs_to :host

    def name
      ipv6.to_s
    end

    def ipv6
      if Kea::Ipv6Reservation.schema_major_version >= 19
        IPAddr.new_ntoh(address)
      else
        IPAddr.new(address)
      end
    end

    def ipv6=(ip)
      self.address =
        if Kea::Ipv6Reservation.schema_major_version >= 19
          ip.hton
        else
          ip.to_s
        end
    end
  end
end
