# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/notice_nodes
  def notice_nodes
    UserMailer.notice_nodes
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/apply_specific_node
  def apply_specific_node
    UserMailer.apply_specific_node
  end
end
