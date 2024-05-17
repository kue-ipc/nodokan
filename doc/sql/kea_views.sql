-- sql views for kea

CREATE OR REPLACE VIEW ipv6_reservations_alt AS SELECT
  reservation_id,
  address,
  prefix_len,
  type AS reservation_type,
  dhcp6_iaid,
  host_id FROM ipv6_reservations;

CREATE OR REPLACE VIEW host_identifier_type_alt AS SELECT
  type AS identifier_type,
  name FROM host_identifier_type;
