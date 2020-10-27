class NetworkUser < ApplicationRecord
  belongs_to :network
  belongs_to :user

  validates :network, presence: true, uniqueness: {
    scope: :user,
  }

  validates :user, presence: true

end
