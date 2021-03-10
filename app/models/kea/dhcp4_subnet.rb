# CREATE TABLE `dhcp4_subnet` (
#   `subnet_id` int(10) unsigned NOT NULL,
#   `subnet_prefix` varchar(32) NOT NULL,
#   `4o6_interface` varchar(128) DEFAULT NULL,
#   `4o6_interface_id` varchar(128) DEFAULT NULL,
#   `4o6_subnet` varchar(64) DEFAULT NULL,
#   `boot_file_name` varchar(512) DEFAULT NULL,
#   `client_class` varchar(128) DEFAULT NULL,
#   `interface` varchar(128) DEFAULT NULL,
#   `match_client_id` tinyint(1) DEFAULT NULL,
#   `modification_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
#   `next_server` int(10) unsigned DEFAULT NULL,
#   `rebind_timer` int(10) DEFAULT NULL,
#   `relay` longtext DEFAULT NULL,
#   `renew_timer` int(10) DEFAULT NULL,
#   `require_client_classes` longtext DEFAULT NULL,
#   `reservation_mode` tinyint(3) DEFAULT NULL,
#   `server_hostname` varchar(512) DEFAULT NULL,
#   `shared_network_name` varchar(128) DEFAULT NULL,
#   `user_context` longtext DEFAULT NULL,
#   `valid_lifetime` int(10) DEFAULT NULL,
#   `authoritative` tinyint(1) DEFAULT NULL,
#   `calculate_tee_times` tinyint(1) DEFAULT NULL,
#   `t1_percent` float DEFAULT NULL,
#   `t2_percent` float DEFAULT NULL,
#   `min_valid_lifetime` int(10) DEFAULT NULL,
#   `max_valid_lifetime` int(10) DEFAULT NULL,
#   PRIMARY KEY (`subnet_id`),
#   UNIQUE KEY `subnet4_subnet_prefix` (`subnet_prefix`),
#   KEY `fk_dhcp4_subnet_shared_network` (`shared_network_name`),
#   KEY `key_dhcp4_subnet_modification_ts` (`modification_ts`),
#   CONSTRAINT `fk_dhcp4_subnet_shared_network` FOREIGN KEY (`shared_network_name`) REFERENCES `dhcp4_shared_network` (`name`) ON DELETE SET NULL ON UPDATE NO ACTION
# )
module Kea
  class Dhcp4Subnet < KeaRecord
    self.table_name = 'dhcp4_subnet'
    self.primary_key = 'subnet_id'
  end
end
