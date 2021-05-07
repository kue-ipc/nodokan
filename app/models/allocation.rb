class Allocation < ApplicationRecord
  belongs_to :user
  belongs_to :network, counter_cache: true

  def needed?
    usable || auth
  end
end
