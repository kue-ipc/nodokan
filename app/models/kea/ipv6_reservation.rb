module Kea
  class Ipv6Reservation < KeaRecord
    self.table_name = 'ipv6_reservations_alt'
    self.primary_key = 'reservation_id'

    enum reservation_type: {
      address: 0,
      prefix: 2,
    }, _prefix: :type

    belongs_to :host, primary_key: 'host_id'
  end
end
