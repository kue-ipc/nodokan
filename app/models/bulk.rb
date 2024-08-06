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
    :cancel,
    :error,
    :timeout,
    :nothing,
  ], validate: true

  belongs_to :user
  has_one_attached :input
  has_one_attached :output

  validates :target,
    inclusion: {in: ["Node", "Confirmation", "Network", "User"]}

  before_update :check_status_transition

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

  def check_status_transition
    case status_change
    in nil
      # ok
    in _, "error"
      # ok
    in "waiting" | "starting" | "running" | "stopping", _
      # ok
    in "stopped" | "succeeded" | "failed" | "cancel" | "error" | "timeout" |
      "nothing", _
      throw :abort
    else
      Rails.logger.warn("Unmatched pattern: #{status_change}")
      throw :abort
    end
  end

  def register_job
    BulkRunJob.set(wait: 10.seconds).perform_later(self)
  end
end
