module UniqueIdentifier
  extend ActiveSupport::Concern

  included do
    @id_read_list = []
    @id_find_map = {}
  end

  class_methods do
    def unique_identifier(key, attr = nil, read: nil, find: nil)
      read ||= attr
      @id_read_list << [key, read.to_proc]

      find ||= attr
      if find.is_a?(Symbol)
        name = find
        find = ->(value) { find_by!({name => value}) }
      end
      @id_find_map[key] = find.to_proc if find
    end

    def read_identifier(record)
      @id_read_list.each do |key, proc|
        value = class_exec(record, &proc)
        return "#{key}#{value}" if value.present?
      end
      "##{record.id}"
    end

    def find_identifier(str)
      m = /\A(?<key>.)(?<value>.+)\z/.match(str.to_s.strip.downcase)
      raise ArgumentError, "Invalid identifier format: #{str}" unless m

      if (proc = @id_find_map[m[:key]])
        class_exec(m[:value], &proc) ||
          raise(ActiveRecord::RecordNotFound,
            "Couldn't find #{model_name} with 'identifier'=#{str}")
      elsif m[:key] == "#"
        find(m[:value])
      else
        raise ArgumentError, "Unknown identifier type: #{str}"
      end
    end

    def find_ip_address(value, ipv4: :ipv4, ipv6: :ipv6)
      ip = IPAddr.new(value)
      name =
        if ip.ipv4?
          "#{ipv4}_data"
        elsif ip.ipv6?
          "#{ipv6}_data"
        else
          raise ArgumentError, "Unknown IP version: #{str}"
        end
      where(":name = :value", name:, value: ip.hton).first!
    rescue IPAddr::InvalidAddressError
      raise ArgumentError, "Invalid IP address: #{str}"
    end
  end

  def identifier
    self.class.read_identifier(self)
  end
end
