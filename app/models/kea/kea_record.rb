module Kea
  # rubocop:disable Rails/ApplicationRecord
  class KeaRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: {writing: :kea}
    before_save :set_disable_audit
    before_destroy :set_disable_audit

    def set_disable_audit
      self.class.connection.execute('SET @disable_audit = 1;')
    end
  end
  # rubocop:enable Rails/ApplicationRecord
end
