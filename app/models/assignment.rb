class Assignment < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :network, counter_cache: true

  validates :network, uniqueness: { scope: :user }

  scope :unassigned, -> { where(auth: false, use: false, manage: false) }

  def assigned?
    auth || use || manage
  end
end
