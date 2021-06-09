# Preview all emails at http://localhost:3000/rails/mailers/specific_node_mailer
class SpecificNodeMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/specific_node_mailer/apply
  def apply
    SpecificNodeMailer.apply
  end

  # Preview this email at http://localhost:3000/rails/mailers/specific_node_mailer/notify_change
  def notify_change
    SpecificNodeMailer.notify_change
  end

end
