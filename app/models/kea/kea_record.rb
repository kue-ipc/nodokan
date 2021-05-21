module Kea
  # rubocop:disable Rails/ApplicationRecord
  class KeaRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: {writing: :kea}
    before_save :set_disable_audit
    before_destroy :set_disable_audit

    def set_disable_audit
      # self.class.connection.execute('SET @disable_audit = 1;')
      self.class.connection.execute <<-SQL
        INSERT INTO dhcp4_audit_revision
        (modification_ts, server_id, log_message)
        VALUES (NOW(), 1, '');
      SQL
      self.class.connection.execute('SET @audit_revision_id = LAST_INSERT_ID();')
      self.class.connection.execute('SET @cascade_transaction = 0;')
      # SET @audit_revision_id = LAST_INSERT_ID();
    end
  end
  # rubocop:enable Rails/ApplicationRecord
end
