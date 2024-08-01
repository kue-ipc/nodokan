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
  has_one_attached :input
  has_one_attached :output

  after_create_commit :register_job

  def register_job
    BulkRunJob.perform_later(self)
  end
end
