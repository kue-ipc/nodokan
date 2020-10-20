module Kea
  # rubocop:disable Rails/ApplicationRecord
  class KeaRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: {writing: :kea}
  end
  # rubocop:enable Rails/ApplicationRecord
end
