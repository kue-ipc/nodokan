module Identifiers
  extend ActiveSupport::Concern
  include SafeChar

  class Identifier
    attr_reader :key

    def initialize(key, read:, find:)
      @key = key
      @read_proc = read.to_proc
      @find_proc = find.to_proc
    end

    def read(record)
      @read_proc.call(record).presence&.then { |value| "#{key}#{value}" }
    end

    def find(value)
      @find_proc.call(value.delete_prefix(key)) if value.start_with?(key)
    end
  end

  included do
    @identifiers= []
    @id_identifier = Identifier.new("/", read: :id.to_proc, find: self.method(:find))
  end

  class_methods do
    def identifiers(key, name = nil, read: nil, find: nil)
      check_safe_char(key)
      if name
        read ||= name.to_proc
        find ||=  ->(value) { find_by({name => value}) }
      end
      raise ArgumentError, "Either name or read and find procs must be provided" unless read && find

      @identifiers << Identifier.new(key, read:, find:)
    end

    def read_identifier(record)
      @identifiers.each do |identifier|
        str = identifier.read(record)
        return str if str
      end
      @id_identifier.read(record)
    end

    def find_by_identifier(str)
      @identifiers.each do |identifier|
        record = identifier.find(str)
        return record if record
      end
      @id_identifier.find(str)
    end

    def find_by_identifier!(str)
      find_by_identifier(str) ||
        raise(ActiveRecord::RecordNotFound, "Couldn't find #{model_name} with 'identifier'=#{str}")
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
        end.intern
      where({name => ip.hton}).first
    rescue IPAddr::InvalidAddressError
      raise ArgumentError, "Invalid IP address: #{str}"
    end
  end

  def identifier
    self.class.read_identifier(self)
  end
end
