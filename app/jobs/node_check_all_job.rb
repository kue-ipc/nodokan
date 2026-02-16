class NodeCheckAllJob < ApplicationJob
  queue_as :check

  def perform(time = Time.current)
    check_user_nodes(time)
    check_deleted_users_nodes(time)
    check_unowned_nodes(time)
  end

  def check_user_nodes(time = Time.current)
    per_user_jobs = Uesr.where(deleted: false).map { |user| NodeCheckPerUserJob.new(user) }
    ActiveJob.perform_all_later(per_user_jobs)
  end

  def check_deleted_users_nodes(time = Time.current)
    # rubocop:disable Rails/SkipsModelValidations
    count = Node.where.not(notice: "deleted_owner")
      .or(Node.where(noticed_at: nil))
      .or(Node.where(noticed_at: ...(Time.current - Node.notice_interval)))
      .joins(:user).where(user: {deleted: true})
      .update_all(notice: "deleted_owner", noticed_at: nil)
    # rubocop:enable Rails/SkipsModelValidations
    NoticeNodesMaler.deleted_users.deliver_later if count.positive?
  end

  def check_unowned_nodes(time = Time.current)
    # rubocop:disable Rails/SkipsModelValidations
    count = Node.where.not(notice: "unowned")
      .or(Node.where(noticed_at: nil))
      .or(Node.where(noticed_at: ...(Time.current - Node.notice_interval)))
      .where(user: nil)
      .update_all(notice: "unowned", noticed_at: nil)
    # rubocop:enable Rails/SkipsModelValidations
    NoticeNodesMaler.deleted_users.deliver_later if count.positive?
    end
  end
end
