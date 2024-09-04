module Kea
  class Ipv6Reservation < KeaRecord
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
      IPAddr.new_ntoh(address)
    end

    def ipv6=(ip)
      self.address = ip.hton
    end
  end
end
