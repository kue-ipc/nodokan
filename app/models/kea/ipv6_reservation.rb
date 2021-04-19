# Kea DHCP MySQL
# CREATE TABLE `ipv6_reservations` (
#   `reservation_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
#   `address` varchar(39) NOT NULL,
#   `prefix_len` tinyint(3) unsigned NOT NULL DEFAULT 128,
#   `type` tinyint(4) unsigned NOT NULL DEFAULT 0,
#   `dhcp6_iaid` int(10) unsigned DEFAULT NULL,
#   `host_id` int(10) unsigned NOT NULL,
#   PRIMARY KEY (`reservation_id`),
#   UNIQUE KEY `key_dhcp6_address_prefix_len` (`address`,`prefix_len`),
#   KEY `fk_ipv6_reservations_host_idx` (`host_id`),
#   CONSTRAINT `fk_ipv6_reservations_Host` FOREIGN KEY (`host_id`) REFERENCES `hosts` (`host_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
# )

module Kea
  class Ipv6Reservation < KeaRecord
    self.table_name = 'ipv6_reservations_alt'
    self.primary_key = 'reservation_id'

    belongs_to :host, optional: true, primary_key: 'host_id'
  end
end
