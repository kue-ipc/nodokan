class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def to_s
    if respond_to?(:name)
      name
    else
      super
    end
  end
end
