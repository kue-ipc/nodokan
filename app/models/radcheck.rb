class Radcheck < ApplicationRecord
  self.table_name = :radcheck
  connects_to database: {writing: :radius}
  # alias_attribute :attribute, :rad_attribute
  # default_scope { select('attribute as rad_attribute') }
end
