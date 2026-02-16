class NodeCheckAllJob < ApplicationJob
  queue_as :check

  def perform(time = Time.current)
    check_nodes_owned_by_existing_users
    check_nodes_owned_by_deleted_users
    check_unowned_nodes
  end

  def check_nodes_owned_by_existed_users(time = Time.current)
    per_user_jobs = Uesr.where(deleted: false).map { |user| NodeCheckPerUserJob.new(user) }
    ActiveJob.perform_all_later(per_user_jobs)
  end

  def check_nodes_owned_by_deleted_users(time = Time.current)
    deleted_owner_nodes = []
    Node.join(:user).where(user: {deleted: true}).find_each do |node|
      next if node.notice == "deleted_owner" && (time - node.noticed_at) < Node.notice_interval

      deleted_owner_nodes << node
    end
    deleted_owner_nodes
  end

  def check_unowned_nodes(time = Time.current)
    Node.where(user: nil).find_each do |user|
      # TODO: ここに処理
    end
  end
end
