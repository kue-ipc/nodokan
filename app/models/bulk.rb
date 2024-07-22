class Bulk < ApplicationRecord
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
  ], validates: true

  belongs_to :user
  has_one_attached :file
  has_one_attached :result
end
