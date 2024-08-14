module Kea
  class Dhcp6Option < KeaRecord
    include Kea::DhcpOption

    # https://kea.readthedocs.io/en/kea-2.2.0/arm/dhcp6-srv.html#standard-dhcpv6-options
    # name code type array
    # rubocop: disable Layout/LineLength
    dhcp_option [
      ["preference", 7, "uint8", false],
      ["unicast", 12, "ipv6-address", false],
      ["sip-server-dns", 21, "fqdn", true],
      ["sip-server-addr", 22, "ipv6-address", true],
      ["dns-servers", 23, "ipv6-address", true],
      ["domain-search", 24, "fqdn", true],
      ["nis-servers", 27, "ipv6-address", true],
      ["nisp-servers", 28, "ipv6-address", true],
      ["nis-domain-name", 29, "fqdn", true],
      ["nisp-domain-name", 30, "fqdn", true],
      ["sntp-servers", 31, "ipv6-address", true],
      ["information-refresh-time", 32, "uint32", false],
      ["bcmcs-server-dns", 33, "fqdn", true],
      ["bcmcs-server-addr", 34, "ipv6-address", true],
      ["geoconf-civic", 36, "record (uint8, uint16, binary)", false],
      ["remote-id", 37, "record (uint32, binary)", false],
      ["subscriber-id", 38, "binary", false],
      ["client-fqdn", 39, "record (uint8, fqdn)", false],
      ["pana-agent", 40, "ipv6-address", true],
      ["new-posix-timezone", 41, "string", false],
      ["new-tzdb-timezone", 42, "string", false],
      ["ero", 43, "uint16", true],
      ["lq-query", 44, "record (uint8, ipv6-address)", false],
      ["client-data", 45, "empty", false],
      ["clt-time", 46, "uint32", false],
      ["lq-relay-data", 47, "record (ipv6-address, binary)", false],
      ["lq-client-link", 48, "ipv6-address", true],
      ["v6-lost", 51, "fqdn", false],
      ["capwap-ac-v6", 52, "ipv6-address", true],
      ["relay-id", 53, "binary", false],
      ["v6-access-domain", 57, "fqdn", false],
      ["sip-ua-cs-list", 58, "fqdn", true],
      ["bootfile-url", 59, "string", false],
      ["bootfile-param", 60, "tuple", true],
      ["client-arch-type", 61, "uint16", true],
      ["nii", 62, "record (uint8, uint8, uint8)", false],
      ["aftr-name", 64, "fqdn", false],
      ["erp-local-domain-name", 65, "fqdn", false],
      ["rsoo", 66, "empty", false],
      ["pd-exclude", 67, "binary", false],
      ["rdnss-selection", 74, "record (ipv6-address, uint8, fqdn)", true],
      ["client-linklayer-addr", 79, "binary", false],
      ["link-address", 80, "ipv6-address", false],
      ["solmax-rt", 82, "uint32", false],
      ["inf-max-rt", 83, "uint32", false],
      ["dhcp4o6-server-addr", 88, "ipv6-address", true],
      ["s46-rule", 89, "record (uint8, uint8, uint8, ipv4-address, ipv6-prefix)", false],
      ["s46-br", 90, "ipv6-address", false],
      ["s46-dmr", 91, "ipv6-prefix", false],
      ["s46-v4v6bind", 92, "record (ipv4-address, ipv6-prefix)", false],
      ["s46-portparams", 93, "record(uint8, psid)", false],
      ["s46-cont-mape", 94, "empty", false],
      ["s46-cont-mapt", 95, "empty", false],
      ["s46-cont-lw", 96, "empty", false],
      ["v6-captive-portal", 103, "string", false],
      ["ipv6-address-andsf", 143, "ipv6-address", true],
    ]

    self.primary_key = "option_id"

    belongs_to :dhcp_option_scope, foreign_key: "scope_id",
      inverse_of: :dhcp6_options
    belongs_to :dhcp6_subnet, optional: true
    has_and_belongs_to_many :dhcp6_servers, join_table: "dhcp6_options_server",
      foreign_key: "option_id", association_foreign_key: "server_id"
  end
end
