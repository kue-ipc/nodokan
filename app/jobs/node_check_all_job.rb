class NodeCheckAllJob < ApplicationJob
  queue_as :check

  def perform(time: Time.current)
    unless Settings.feature.node_check
      Rails.logger.info "Node check is disabled. Skipping NodeCheckAllJob."
      return
    end

    check_nodes_per_user(time:)
    check_deleted_owner_nodes(time:)
    check_unowned_nodes(time:)
  end

  def check_nodes_per_user(time: Time.current)
    per_user_jobs = User.where(deleted: false).map { |user| NodeCheckPerUserJob.new(user, time:) }
    ActiveJob.perform_all_later(per_user_jobs)
  end

  def check_deleted_owner_nodes(time: Time.current)
    nodes = Node.where.not(notice: "deleted_owner")
      .or(Node.where(noticed_at: nil))
      .or(Node.where(noticed_at: ...(time - Node.notice_interval)))
      .joins(:user).where(user: {deleted: true}).to_a
    NoticeNodesMailer.with(nodes:).deleted_owner.deliver_later if nodes.present?
  end

  def check_unowned_nodes(time: Time.current)
    nodes = Node.where.not(notice: "unowned")
      .or(Node.where(noticed_at: nil))
      .or(Node.where(noticed_at: ...(time - Node.notice_interval)))
      .where(user: nil).to_a
    NoticeNodesMailer.with(nodes:).unowned.deliver_later if nodes.present?
  end
end
