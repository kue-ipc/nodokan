class Assignment < ApplicationRecord
  has_paper_trail

  belongs_to :user, counter_cache: true
  belongs_to :network, counter_cache: true

  validates :network, uniqueness: {scope: :user}

  # neither auth nor use is not assigned
  scope :unassigned, -> { where(auth: false, use: false) }

  before_save :overwrite_if_no_use
  after_save :destroy_if_no_assigned

  def assigned?
    auth || use
  end

  def overwrite_if_no_use
    return if use

    self.default = false
    self.manage = false
  end

  def destroy_if_no_assigned
    destroy unless assigned?
  end

  def name
    "#{user.username} - #{network.identifier}"
  end
end
