module Kea
  class Dhcp4Option < KeaRecord
    # https://kea.readthedocs.io/en/kea-2.2.0/arm/dhcp4-srv.html#dhcp4-std-options-list
    # name code type array
    # rubocop: disable Layout/LineLength
    OPTIONS = [
      ["time-offset", 2, "int32", false],
      ["routers", 3, "ipv4-address", true],
      ["time-servers", 4, "ipv4-address", true],
      ["name-servers", 5, "ipv4-address", true],
      ["domain-name-servers", 6, "ipv4-address", true],
      ["log-servers", 7, "ipv4-address", true],
      ["cookie-servers", 8, "ipv4-address", true],
      ["lpr-servers", 9, "ipv4-address", true],
      ["impress-servers", 10, "ipv4-address", true],
      ["resource-location-servers", 11, "ipv4-address", true],
      ["boot-size", 13, "uint16", false],
      ["merit-dump", 14, "string", false],
      ["domain-name", 15, "fqdn", false],
      ["swap-server", 16, "ipv4-address", false],
      ["root-path", 17, "string", false],
      ["extensions-path", 18, "string", false],
      ["ip-forwarding", 19, "boolean", false],
      ["non-local-source-routing", 20, "boolean", false],
      ["policy-filter", 21, "ipv4-address", true],
      ["max-dgram-reassembly", 22, "uint16", false],
      ["default-ip-ttl", 23, "uint8", false],
      ["path-mtu-aging-timeout", 24, "uint32", false],
      ["path-mtu-plateau-table", 25, "uint16", true],
      ["interface-mtu", 26, "uint16", false],
      ["all-subnets-local", 27, "boolean", false],
      ["broadcast-address", 28, "ipv4-address", false],
      ["perform-mask-discovery", 29, "boolean", false],
      ["mask-supplier", 30, "boolean", false],
      ["router-discovery", 31, "boolean", false],
      ["router-solicitation-address", 32, "ipv4-address", false],
      ["static-routes", 33, "ipv4-address", true],
      ["trailer-encapsulation", 34, "boolean", false],
      ["arp-cache-timeout", 35, "uint32", false],
      ["ieee802-3-encapsulation", 36, "boolean", false],
      ["default-tcp-ttl", 37, "uint8", false],
      ["tcp-keepalive-interval", 38, "uint32", false],
      ["tcp-keepalive-garbage", 39, "boolean", false],
      ["nis-domain", 40, "string", false],
      ["nis-servers", 41, "ipv4-address", true],
      ["ntp-servers", 42, "ipv4-address", true],
      ["vendor-encapsulated-options", 43, "empty", false],
      ["netbios-name-servers", 44, "ipv4-address", true],
      ["netbios-dd-server", 45, "ipv4-address", true],
      ["netbios-node-type", 46, "uint8", false],
      ["netbios-scope", 47, "string", false],
      ["font-servers", 48, "ipv4-address", true],
      ["x-display-manager", 49, "ipv4-address", true],
      ["dhcp-option-overload", 52, "uint8", false],
      ["dhcp-server-identifier", 54, "ipv4-address", false],
      ["dhcp-message", 56, "string", false],
      ["dhcp-max-message-size", 57, "uint16", false],
      ["vendor-class-identifier", 60, "string", false],
      ["nwip-domain-name", 62, "string", false],
      ["nwip-suboptions", 63, "binary", false],
      ["nisplus-domain-name", 64, "string", false],
      ["nisplus-servers", 65, "ipv4-address", true],
      ["tftp-server-name", 66, "string", false],
      ["boot-file-name", 67, "string", false],
      ["mobile-ip-home-agent", 68, "ipv4-address", true],
      ["smtp-server", 69, "ipv4-address", true],
      ["pop-server", 70, "ipv4-address", true],
      ["nntp-server", 71, "ipv4-address", true],
      ["www-server", 72, "ipv4-address", true],
      ["finger-server", 73, "ipv4-address", true],
      ["irc-server", 74, "ipv4-address", true],
      ["streettalk-server", 75, "ipv4-address", true],
      ["streettalk-directory-assistance-server", 76, "ipv4-address", true],
      ["user-class", 77, "binary", false],
      ["slp-directory-agent", 78, "record (boolean, ipv4-address)", true],
      ["slp-service-scope", 79, "record (boolean, string)", false],
      ["nds-server", 85, "ipv4-address", true],
      ["nds-tree-name", 86, "string", false],
      ["nds-context", 87, "string", false],
      ["bcms-controller-names", 88, "fqdn", true],
      ["bcms-controller-address", 89, "ipv4-address", true],
      ["client-system", 93, "uint16", true],
      ["client-ndi", 94, "record (uint8, uint8, uint8)", false],
      ["uuid-guid", 97, "record (uint8, binary)", false],
      ["uap-servers", 98, "string", false],
      ["geoconf-civic", 99, "binary", false],
      ["pcode", 100, "string", false],
      ["tcode", 101, "string", false],
      ["v6-only-preferred", 108, "uint32", false],
      ["netinfo-server-address", 112, "ipv4-address", true],
      ["netinfo-server-tag", 113, "string", false],
      ["v4-captive-portal", 114, "string", false],
      ["auto-config", 116, "uint8", false],
      ["name-service-search", 117, "uint16", true],
      ["domain-search", 119, "fqdn", true],
      ["vivco-suboptions", 124, "record (uint32, binary)", false],
      ["vivso-suboptions", 125, "uint32", false],
      ["pana-agent", 136, "ipv4-address", true],
      ["v4-lost", 137, "fqdn", false],
      ["capwap-ac-v4", 138, "ipv4-address", true],
      ["sip-ua-cs-domains", 141, "fqdn", true],
      ["rdnss-selection", 146, "record (uint8, ipv4-address, ipv4-address, fqdn)", true],
      ["v4-portparams", 159, "record (uint8, psid)", false],
      ["option-6rd", 212, "record (uint8, uint8, ipv6-address, ipv4-address)", true],
      ["v4-access-domain", 213, "fqdn", false],
    ]
    # rubocop: enable Layout/LineLength

    self.primary_key = "option_id"

    belongs_to :dhcp4_subnet, primary_key: "subnet_id", optional: true
    belongs_to :dhcp_option_scope, primary_key: "scope_id",
      foreign_key: "scope_id", inverse_of: :dhcp4_options

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
