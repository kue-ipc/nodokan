module Kea
  # rubocop:disable Rails/ApplicationRecord
  class KeaRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: {writing: :kea}

    def self.no_audit
      connection.execute("SET @disable_audit = 1;")
    end

    def self.dhcp4_audit
      connection.execute('CALL createAuditRevisionDHCP4(NOW(), "all", "", 0)')
    end

    def self.dhcp6_audit
      connection.execute('CALL createAuditRevisionDHCP6(NOW(), "all", "", 0)')
    end
  end
  # rubocop:enable Rails/ApplicationRecord
end
