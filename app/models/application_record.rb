class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  has_paper_trail

  def to_s
    if respond_to?(:name)
      name
    else
      super
    end
  end
end
