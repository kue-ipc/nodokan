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

      data_length =
        if version == 4
          4
        else
          16
        end

      validates :"#{name}_address", allow_blank: allow_nil,
        "ipv#{version}_address": true
      validates_each :"#{name}", allow_nil: allow_nil do |record, attr, value|
        if value && !value.__send__(:"ipv#{version}?")
          record.errors.add(attr, I18n.t("errors.messages.not_ipv{version}"))
        end
      end
      validates :"#{name}_data", allow_nil: allow_nil, length: {is: data_length}

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

      define_method(:"#{name}_global?") do
        if version == 4
          __send__(name)&.then do |ip|
            !ip.loopback? && !ip.link_local? && !ip.private? &&
              (1...240).cover?(ip.to_i >> 24) # 1.0.0.0 <= ip < 240.0.0.0
          end
        else
          __send__(name)&.then { |ip| ip.to_i >> 125 == 1 } # 2000::/3
        end
      end

      define_method(:"replace_#{name}_errors") do
        replace_error(:"#{name}_data", :"#{name}_address")
        replace_error(name, :"#{name}_address")
      end
    end
  end
end
