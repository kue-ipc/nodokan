class Bulk < ApplicationRecord
  has_paper_trail

  enum :status, [
    :waiting,
    :starting,
    :running,
    :stopping,
    :stopped,
    :succeeded,
    :failed,
    :canceled,
    :error,
    :timeout,
  ], validate: true

  belongs_to :user
  has_one_attached :file
  has_one_attached :result
end
