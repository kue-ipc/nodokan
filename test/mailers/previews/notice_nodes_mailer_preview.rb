class NoticeNodesMailerPreview < ActionMailer::Preview
  def destroy_soon
    NoticeNodesMailer.with(ids: Node.limit(3).ids, user: User.first).destroy_soon
  end
end
