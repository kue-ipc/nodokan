module Kea
  module DhcpOption
    extend ActiveSupport::Concern

    class_methods do
      def dhcp_option(list)
        options = list.map { |opt| Kea::DhcpOption::Option.new(*opt) }
        options_name_map = options.index_by(&:name)
        options_code_map = options.index_by(&:code)

        define_method(:option_by_name) do |name|
          options_name_map.fetch(name)
        end

        define_method(:option_by_code) do |code|
          options_code_map.fetch(code)
        end
      end

      def normalize_name(name)
        name.to_s.downcase.gsub("_", "-")
      end
    end

    included do
      attribute :name, :string
      validates :code, presence: true, numericality: {only_integer: true}
    end

    def option
      return if code.nil?

      option_by_code(code)
    end

    def name
      option&.name
    end

    def name=(value)
      if value.blank?
        self.code = nil
        return
      end

      option = option_by_name(self.class.normalize_name(value))
      self.code = option.code
    end

    def data
      if formatted_value
        option&.from_formatted_value(formatted_value)
      elsif value
        option&.to_formatted_value(value)
      end
    end

    def data=(value)
      self.formatted_value = option&.to_formatted_value(value)
    end

    # https://kea.readthedocs.io/en/kea-2.2.0/arm/dhcp4-srv.html#id4
    class Option
      attr_reader :name, :code, :type, :array

      def initialize(name, code, type, array)
        @name = -name
        @code = code
        @type = -type
        @array = array
      end

      def array?
        array
      end

      def from_value(_value, type: @type, array: @array)
        raise "Conversion from value is not implemented"
      end

      def from_formatted_value(value, type: @type, array: @array)
        if type.start_with?("record")
          raise "Conversion is not implemented for record type"
        end

        if array
          return value.split(",").map(&:strip)
              .map { |v| from_formatted_value(v, type:, array: false) }
        end

        case type
        when "binary" then [value].pack("H*")
        when "boolean" then value == "true"
        when "empty" then nil
        when "fqdn" then value.strip.to_s
        when "ipv4-address" then to_ip(value, version: 4)
        when "ipv6-address", "ipv6-prefix" then to_ip(value, version: 6)
        when "psid" then raise "Conversion is not implemented for psid type"
        when "string" then value.to_s
        when "tuple" then raise "Conversion is not implemented for tuple type"
        when "uint8", "uint16", "uint32", "int8", "int16", "int32"
          # FIXME: 大きさをチェックしていない
          value.to_i
        else raise "Unknown type: #{type}"
        end
      end

      def to_value(_obj, type: @type, array: @array)
        raise "Conversion to value is not implemented"
      end

      def to_formatted_value(obj, type: @type, array: @array)
        if type.start_with?("record")
          raise "Conversion is not implemented for record type"
        end

        if array
          return Array(obj)
              .map { |v| to_formatted_value(v, type:, array: false) }
              .join(",")
        end

        case type
        when "binary" then obj.unpack1("H*")
        when "boolean" then (!!obj).to_s
        when "empty" then ""
        when "fqdn" then obj.strip.to_s
        when "ipv4-address" then to_ip(obj, version: 4).to_s
        when "ipv6-address" then to_ip(obj, version: 6).to_s
        when "ipv6-prefix"
          to_ip(obj, version: 6).then { |ip| "#{ip}/#{ip.prefix}" }
        when "psid" then raise "Conversion is not implemented for psid type"
        when "string" then obj.to_s
        when "tuple" then raise "Conversion is not implemented for tuple type"
        when "uint8", "uint16", "uint32", "int8", "int16", "int32"
          # FIXME: 大きさをチェックしていない
          obj.to_i.to_s
        else raise "Unknown type: #{type}"
        end
      end

      private def to_ip(obj, version: 4)
        family =
          case version
          when 4 then Socket::AF_INET
          when 6 then Socket::AF_INET6
          else raise ArgumentError, "IP version must be 4 or 6"
          end
        ip =
          case obj
          when IPAddr then obj
          when Integer then IPAddr.new(obj, family)
          when String then IPAddr.new(obj)
          else raise ArgumentError, "Cannot convert to IP Address"
          end
        raise ArgumentError, "IP Address family mismatch" if ip.family != family

        ip
      end
    end
  end
end
