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
    :nothing,
  ], validate: true

  belongs_to :user
  has_one_attached :input
  has_one_attached :output

  validates :target,
    inclusion: {in: ["Node", "Confirmation", "Network", "User"]}

  after_create_commit :register_job

  # class methods

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w(
      id
      target
      status
      created_at
      updated_at
    )
  end

  def self.ransackable_associations(auth_object = nil)
    %w(users)
  end
  # rubocop: enable Lint/UnusedMethodArgument

  def register_job
    BulkRunJob.set(wait: 10.seconds).perform_later(self)
  end
end
