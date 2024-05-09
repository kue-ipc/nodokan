module Kea
  class Dhcp6Option < KeaRecord
    # https://kea.readthedocs.io/en/kea-2.2.0/arm/dhcp6-srv.html#standard-dhcpv6-options
    # name code type array
    # rubocop: disable Layout/LineLength
    OPTIONS = [
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
    # rubocop: enable Layout/LineLength

    self.primary_key = "option_id"

    belongs_to :dhcp6_subnet, primary_key: "subnet_id", optional: true
    belongs_to :dhcp_option_scope, primary_key: "scope_id",
      foreign_key: "scope_id", inverse_of: :dhcp6_options

    validates :code, presence: true, numericality: {only_integer: true}

    attrubite :name, :string
    def name
      return if code.nil?

      OPTIONS.find { |opt| opt[1] == code }&.[](0)
    end

    def name=(value)
      if value.blank?
        self.code = nil
        return
      end

      normalized_name = name.to_s.downcase.gsub("_", "-")
      self.code = OPTIONS.find { |opt| opt[0] == normalized_name }
    end

    def data=(value)
      self.formatted_value = to_formatted_value(value)
    end

    class Option
      attr_reader :name, :code, :type

      def initialize(name, code, type, array)
        @name = name
        @code = code
        @type = type
        @array = array
      end

      def array?
        @array
      end

      def to_value(_value)
        raise "Conversion to value is not implemented"
      end

      def to_formatted_value(value)
        if arary?
          value = Array(value)
          return if value.blank?

          value.map { |_v| _to_formatted_value(value) }.join(",")
        else
          _to_formatted_value(value)
        end
      end

      private def _to_formatted_value(value)
        case type
        when "binary"
          value.unpack1("H*")
        when "boolean"
          if value
            "true"
          else
            "false"
          end
        when "empty"
          ""
        when "fqdn"
          value
        when "ipv4-address"
          to_ip(value, version: 4).to_s
          to_ip(value, version: 6).to_s
        when "ipv6-prefix"
          ip = to_ip(value, version: 6)
          "#{ip}/#{ip.prefix}"
        when "psid"
          raise "Conversion is not implemented: #{type}"
        when "record"
          raise "Conversion is not implemented: #{type}"
        when "string"
          value.to_s
        when "tuple"
          raise "Conversion is not implemented: #{type}"
        when "uint8", "uint16", "uint32", "int8", "int16", "int32"
          # FIXME: チェックしていない
          value.to_i.to_s
        else
          raise "Unknown type: #{type}"
        end
      end
    end

    private def to_ip(value, version: 4)
      family =
        case version
        when 4
          Socket::AF_INET
        when 6
          Socket::AF_INET6
        else
          raise ArgumentError, "IP version must be 4 or 6"
        end
      ip =
        case value
        when IPAddr then value
        when Integer then IPAddr.new(value, family)
        when String then IPAddr.new(value)
        else
          raise ArgumentError, "Cannot convert to IP Address"
        end
      raise ArgumentError, "IP Address family mismatch" if ip.family != family

      ip
    end
  end
end
