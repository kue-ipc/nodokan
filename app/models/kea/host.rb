# Kea DHCP MySQL
# CREATE TABLE `hosts` (
#   `host_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
#   `dhcp_identifier` varbinary(128) NOT NULL,
#   `dhcp_identifier_type` tinyint(4) NOT NULL,
#   `dhcp4_subnet_id` int(10) unsigned DEFAULT NULL,
#   `dhcp6_subnet_id` int(10) unsigned DEFAULT NULL,
#   `ipv4_address` int(10) unsigned DEFAULT NULL,
#   `hostname` varchar(255) DEFAULT NULL,
#   `dhcp4_client_classes` varchar(255) DEFAULT NULL,
#   `dhcp6_client_classes` varchar(255) DEFAULT NULL,
#   `dhcp4_next_server` int(10) unsigned DEFAULT NULL,
#   `dhcp4_server_hostname` varchar(64) DEFAULT NULL,
#   `dhcp4_boot_file_name` varchar(128) DEFAULT NULL,
#   `user_context` text DEFAULT NULL,
#   `auth_key` varchar(32) DEFAULT NULL,
#   PRIMARY KEY (`host_id`),
#   UNIQUE KEY `key_dhcp4_identifier_subnet_id` (`dhcp_identifier`,`dhcp_identifier_type`,`dhcp4_subnet_id`),
#   UNIQUE KEY `key_dhcp6_identifier_subnet_id` (`dhcp_identifier`,`dhcp_identifier_type`,`dhcp6_subnet_id`),
#   UNIQUE KEY `key_dhcp4_ipv4_address_subnet_id` (`ipv4_address`,`dhcp4_subnet_id`),
#   KEY `fk_host_identifier_type` (`dhcp_identifier_type`),
#   CONSTRAINT `fk_host_identifier_type` FOREIGN KEY (`dhcp_identifier_type`) REFERENCES `host_identifier_type` (`type`)
# )

module Kea
  class Host < KeaRecord
    self.primary_key = 'host_id'

    enum dhcp_identifier_type: {
      hw_address: 0,
      duid: 1,
      circuit_id: 2,
      client_id: 3,
      felxible: 4,
    }

    belongs_to :dhcp4_subnet, optional: true
    belongs_to :dhcp6_subnet, optional: true

  end
end
