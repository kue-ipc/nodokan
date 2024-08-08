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

    def self.schema_version
      @schema_version ||=
        connection.select_one("SELECT version,minor FROM schema_version")
          .then { |record| [record["version"], record["minor"]] }
    end

    def self.schema_major_version
      schema_version[0]
    end

    def self.schema_minor_version
      schema_version[1]
    end

    def self.no_audit
      connection.execute("SET @disable_audit = 1;")
    end

    # cascade_transaction
    #   サブネットと一緒にオプションも追加する場合: true
    #   既存のサブネットにオプションを追加する場合: false
    def self.dhcp4_audit(cascade_transaction: false)
      if cascade_transaction
        connection.execute('CALL createAuditRevisionDHCP4(NOW(), "all", "", 1)')
      else
        connection.execute('CALL createAuditRevisionDHCP4(NOW(), "all", "", 0)')
      end
    end

    def self.dhcp6_audit(cascade_transaction: false)
      if cascade_transaction
        connection.execute('CALL createAuditRevisionDHCP6(NOW(), "all", "", 1)')
      else
        connection.execute('CALL createAuditRevisionDHCP6(NOW(), "all", "", 0)')
      end
    end
  end
  # rubocop:enable Rails/ApplicationRecord
end
