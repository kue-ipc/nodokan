module Kea
  # rubocop:disable Rails/ApplicationRecord
  class KeaRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: {writing: :kea}

    def to_s
      if respond_to?(:name)
        name
      else
        super
      end
    end

    def self.no_audit
      connection.execute("SET @disable_audit = 1;")
    end

    def self.dhcp4_audit
      connection.execute('CALL createAuditRevisionDHCP4(NOW(), "all", "", 0)')
    end

    def self.dhcp6_audit
      connection.execute('CALL createAuditRevisionDHCP6(NOW(), "all", "", 0)')
    end

    # https://kea.readthedocs.io/en/kea-2.2.0/arm/dhcp4-srv.html#id4
    class DhcpOptionType
      attr_reader :name, :code, :type, :array

      def initialize(name, code, type, array)
        @name = -name
        @code = code
        @type = -type
        @array = array
      end

      def array?
        @array
      end

      def to_value(_value)
        raise "Conversion to value is not implemented"
      end

      def to_formatted_value(value, type: @type, array: @array)
        if type.start_with?("record")
          raise "Conversion is not implemented for record type"
        end

        if array
          value = Array(value)
          return if value.blank?

          return value
              .map { |v| to_formatted_value(v, type: type, array: false) }
              .join(",")
        end

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
        when "ipv6-address"
          to_ip(value, version: 6).to_s
        when "ipv6-prefix"
          ip = to_ip(value, version: 6)
          "#{ip}/#{ip.prefix}"
        when "psid"
          raise "Conversion is not implemented for psid type"
        when "string"
          value.to_s
        when "tuple"
          raise "Conversion is not implemented for tuple type"
        when "uint8", "uint16", "uint32", "int8", "int16", "int32"
          # FIXME: 大きさをチェックしていない
          value.to_i.to_s
        else
          raise "Unknown type: #{type}"
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
  # rubocop:enable Rails/ApplicationRecord
end
