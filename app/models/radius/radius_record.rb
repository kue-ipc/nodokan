module Radius
  # rubocop:disable Rails/ApplicationRecord
  class RadiusRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: { writing: :radius }
  end
  # rubocop:enable Rails/ApplicationRecord
end
