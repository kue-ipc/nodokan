module Kea
  class KeaRecord < ActiveRecord::Base
    self.abstract_class = true

    connects_to database: {writing: :kea}
  end
end
