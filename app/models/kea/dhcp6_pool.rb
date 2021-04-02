# CREATE TABLE `dhcp4_pool` (
#   `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
#   `start_address` int(10) unsigned NOT NULL,
#   `end_address` int(10) unsigned NOT NULL,
#   `subnet_id` int(10) unsigned NOT NULL,
#   `modification_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
#   `client_class` varchar(128) DEFAULT NULL,
#   `require_client_classes` longtext DEFAULT NULL,
#   `user_context` longtext DEFAULT NULL,
#   PRIMARY KEY (`id`),
#   KEY `key_dhcp4_pool_modification_ts` (`modification_ts`),
#   KEY `fk_dhcp4_pool_subnet_id` (`subnet_id`),
#   CONSTRAINT `fk_dhcp4_pool_subnet_id` FOREIGN KEY (`subnet_id`) REFERENCES `dhcp4_subnet` (`subnet_id`) ON DELETE NO ACTION ON UPDATE CASCADE
# )

module Kea
  class Dhcp6Pool < KeaRecord
    self.table_name = 'dhcp6_pool'

    belongs_to :subnet, class_name: 'Dhcp6Subnet', primary_key: 'subnet_id'
  end
end
