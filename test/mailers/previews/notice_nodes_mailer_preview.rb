class NoticeNodesMailerPreview < ActionMailer::Preview
  def unowned
    NoticeNodesMailer.with(nodes: Node.limit(3)).unowned
  end

  def deleted_owner
    NoticeNodesMailer.with(nodes: Node.limit(3)).deleted_owner
  end

  def destroyed
    NoticeNodesMailer.with(nodes: Node.limit(3).map(&:serializable_hash), user: User.first, bulk: Bulk.first).destroyed
  end

  def destroy_soon
    NoticeNodesMailer.with(nodes: Node.limit(3), user: User.first).destroy_soon
  end

  def disabled
    NoticeNodesMailer.with(nodes: Node.limit(3), user: User.first).disabled
  end

  def disable_soon
    NoticeNodesMailer.with(nodes: Node.limit(3), user: User.first).disable_soon
  end

  def unconfirmed
    NoticeNodesMailer.with(nodes: Node.limit(3), user: User.first).unconfirmed
  end

  def approved
    NoticeNodesMailer.with(nodes: Node.limit(3), user: User.first).approved
  end

  def unapproved
    NoticeNodesMailer.with(nodes: Node.limit(3), user: User.first).unapproved
  end

  def expired
    NoticeNodesMailer.with(nodes: Node.limit(3), user: User.first).expired
  end

  def exire_soon
    NoticeNodesMailer.with(nodes: Node.limit(3), user: User.first).expire_soon
  end
end
