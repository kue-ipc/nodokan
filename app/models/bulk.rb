class Bulk < ApplicationRecord
  include CleanRecord

  has_paper_trail

  enum :status, {
    waiting: 0,
    starting: 1,
    running: 2,
    stopping: 3,
    stopped: 4,
    succeeded: 5,
    failed: 6,
    cancel: 7,
    error: 8,
    timeout: 9,
    nothing: 10,
  }, validate: true

  belongs_to :user
  has_one_attached :input
  has_one_attached :output

  validates :target, inclusion: {in: ["Node", "Confirmation", "Network", "User"]}
  validates :content_type, inclusion: {in: ["text/csv", "application/yaml", "application/jsonl"]}, allow_nil: true
  validates :input, presence: true, if: ->(bulk) { bulk.content_type.nil? }

  before_update :check_status_transition

  after_create_commit :register_job

  # class methods

  # rubocop: disable Lint/UnusedMethodArgument
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id
      target
      status
      created_at
      updated_at
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[users]
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
    if input.attached?
      BulkRunJob.set(wait: 1.second).perform_later(self)
    else
      BulkRunJob.perform_later(self)
    end
  end
end
