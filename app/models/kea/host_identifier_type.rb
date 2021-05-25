module Kea
  class HostIdentifierType < KeaRecord
    self.primary_key = 'identifier_type'
    self.table_name = 'host_identifier_type_alt'

    has_many :hosts,
      foreign_key: 'dhcp_identifier_type', primary_key: 'identifier_type',
      inverse_of: :host_identifier_type

    def readonly?
      true
    end

    def self.hw_address
      self.find_by(name: 'hw-address')
    end

    def self.duid
      self.find_by(name: 'duid')
    end
  end
end
