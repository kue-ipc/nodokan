class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :network, counter_cache: true

  validates :network, uniqueness: { scope: :user }

  scope :unassigned, -> { where(auth: false, use: false, manage: false) }


  def assigned?
    auth || use || manage
  end
end
