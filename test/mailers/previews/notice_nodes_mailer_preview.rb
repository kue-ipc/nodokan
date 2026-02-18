# Preview all emails at http://localhost:3000/rails/mailers/notice_nodes_mailer
class NoticeNodesMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/notice_nodes_mailer/user
  def user
    NoticeNodesMailer.user
  end

  # Preview this email at http://localhost:3000/rails/mailers/notice_nodes_mailer/deleted_users
  def deleted_users
    NoticeNodesMailer.deleted_users
  end

  # Preview this email at http://localhost:3000/rails/mailers/notice_nodes_mailer/unowned
  def unowned
    NoticeNodesMailer.unowned
  end
end
