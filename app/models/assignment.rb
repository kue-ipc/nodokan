class Assignment < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :network, counter_cache: true

  validates :network, uniqueness: { scope: :user }

  scope :unassigned, -> { where(auth: false, use: false, manage: false) }

  after_save :destroy_if_no_assigned

  def assigned?
    auth || use || manage
  end

  def destroy_if_no_assigned
    destroy unless assigned?
  end

  def name
    "#{user.username} - #{network.identifier}"
  end
end
