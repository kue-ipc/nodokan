module Radius
  # rubocop:disable Rails/ApplicationRecord
  class RadiusRecord < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: {writing: :radius}

    def to_s
      if respond_to?(:name)
        name
      else
        super
      end
    end
  end
  # rubocop:enable Rails/ApplicationRecord
end
