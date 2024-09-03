module IpData
  extend ActiveSupport::Concern
  include ReplaceError

  class_methods do
    def ipv4_data(name, **opts)
      ip_data(name, **opts, version: 4)
    end

    def ipv6_data(name, **opts)
      ip_data(name, **opts, version: 6)
    end

    def ip_data(name, version:, allow_nil: false)
      name = name.intern

      raise "IP version must be 4 or 6: #{version}" if [4, 6].exclude?(version)

      case version
      in 4
        validates :"#{name}_data", allow_nil:, length: {is: 4}
        validates :"#{name}_address", allow_blank: allow_nil,
          ipv4_address: true
        validates_each(:"#{name}", allow_nil:) do |record, attr, value|
          if value && !value.ipv4?
            record.errors.add(attr, I18n.t("errors.messages.not_ipv4"))
          end
        end
      in 6
        validates :"#{name}_data", allow_nil:, length: {is: 16}
        validates :"#{name}_address", allow_blank: allow_nil,
          ipv6_address: true
        validates_each(:"#{name}", allow_nil:) do |record, attr, value|
          if value && !value.ipv6?
            record.errors.add(attr, I18n.t("errors.messages.not_ipv6"))
          end
        end
      end

      after_validation :"replace_#{name}_errors"

      attribute :"#{name}_address", :string

      define_method(name) do
        instance_variable_get(:"@#{name}") ||
          instance_variable_set(:"@#{name}",
            __send__(:"#{name}_data")&.then(&IPAddr.method(:new_ntoh)))
      end

      define_method(:"#{name}=") do |value|
        instance_variable_set(:"@#{name}", value)
        __send__(:"#{name}_data=", value&.hton)
      end

      define_method(:"#{name}_address") do
        instance_variable_get(:"@#{name}_address") ||
          instance_variable_set(:"@#{name}_address", __send__(name)&.to_s)
      end

      define_method(:"#{name}_address=") do |value|
        instance_variable_set(:"@#{name}_address", value)
        __send__(:"#{name}=", value.presence && IPAddr.new(value))
      rescue IPAddr::InvalidAddressError
        __send__(:"#{name}=", nil)
      end

      define_method(:"#{name}_loopback?") do
        __send__(name)&.loopbak?
      end

      define_method(:"#{name}_link_local?") do
        __send__(name)&.link_local?
      end

      define_method(:"#{name}_private?") do
        __send__(name)&.private?
      end

      define_method(:"#{name}_global?") do
        __send__(name)&.then do |ip|
          ip = ip.ipv4_mapped if ip.ipv4_mapped?
          if ip.ipv4?
            !ip.loopback? && !ip.link_local? && !ip.private? &&
              (1...224).cover?(ip.to_i >> 24) # 1.0.0.0 <= ip < 224.0.0.0
          elsif ip.ipv6?
            ip.to_i >> 125 == 1 # 2000::/3
          else
            raise AddressFamilyError, "unsupported address family"
          end
        end
      end

      define_method(:"#{name}_unicast?") do
        __send__(name)&.then do |ip|
          ip = ip.ipv4_mapped if ip.ipv4_mapped?
          if ip.ipv4?
            ip.to_i >> 28 != 0xe && # 224.0.0.0/4ではない
              ip.to_i != 0xffffffff # 255.255.255.255ではない
          elsif ip.ipv6?
            ip.to_i >> 120 != 0xff # ff00::/8ではない
          else
            raise AddressFamilyError, "unsupported address family"
          end
        end
      end

      define_method(:"#{name}_multicast?") do
        __send__(name)&.then do |ip|
          ip = ip.ipv4_mapped if ip.ipv4_mapped?
          if ip.ipv4?
            ip.to_i >> 28 == 0xe # 224.0.0.0/4
          elsif ip.ipv6?
            ip.to_i >> 120 == 0xff # ff00::/8
          else
            raise AddressFamilyError, "unsupported address family"
          end
        end
      end

      define_method(:"#{name}_broadcast?") do
        __send__(name)&.then do |ip|
          ip = ip.ipv4_mapped if ip.ipv4_mapped?
          if ip.ipv4?
            __send__(name)&.to_i&.==(0xffffffff) # 255.255.255.255
          elsif ip.ipv6?
            false
          else
            raise AddressFamilyError, "unsupported address family"
          end
        end
      end

      define_method(:"#{name}_unspecified?") do
        __send__(name)&.to_i&.zero?
      end

      define_method(:"replace_#{name}_errors") do
        replace_error(:"#{name}_data", :"#{name}_address")
        replace_error(name, :"#{name}_address")
      end
      private :"replace_#{name}_errors"
    end
  end
end
