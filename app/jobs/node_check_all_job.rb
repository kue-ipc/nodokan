class NodeCheckAllJob < ApplicationJob
  queue_as :check

  def perform(time = Time.current)
    check_nodes_owned_by_existing_users(time)
    check_nodes_owned_by_deleted_users(time)
    check_unowned_nodes(time)
  end

  def check_nodes_owned_by_existing_users(time = Time.current)
    per_user_jobs = Uesr.where(deleted: false).map { |user| NodeCheckPerUserJob.new(user) }
    ActiveJob.perform_all_later(per_user_jobs)
  end

  def check_nodes_owned_by_deleted_users(time = Time.current)
    ids = Node.where.not(notice: "deleted_owner")
      .or(Node.where(noticed_at: nil))
      .or(Node.where(noticed_at: ...(time - Node.notice_interval)))
      .joins(:user).where(user: {deleted: true})
      .ids
    NoticeNodesMaler.with(ids:).deleted_owner.deliver_later if ids.present?
  end

  def check_unowned_nodes(time = Time.current)
    ids = Node.where.not(notice: "unowned")
      .or(Node.where(noticed_at: nil))
      .or(Node.where(noticed_at: ...(time - Node.notice_interval)))
      .where(user: nil)
      .ids
    NoticeNodesMaler.with(ids:).unowned.deliver_later if count.positive?
    end
  end
end
