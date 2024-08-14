module Kea
  class HostIdentifierType < KeaRecord
    self.table_name = "host_identifier_type"
    # type attribute is not an inheritence column
    self.inheritance_column = "inheritance_type"
    self.primary_key = "type"

    has_many :hosts, foreign_key: "dhcp_identifier_type",
      inverse_of: :host_identifier_type

    def readonly?
      true
    end

    def self.hw_address
      find_by(name: "hw-address")
    end

    def self.duid
      find_by(name: "duid")
    end

    def self.circuit_id
      find_by(name: "circuit-id")
    end

    def self.client_id
      find_by(name: "client-id")
    end

    def self.flex_id
      find_by(name: "flex-id")
    end
  end
end
