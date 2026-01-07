# Preview all emails at http://localhost:3000/rails/mailers/specific_node_mailer
class SpecificNodeMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/specific_node_mailer/apply
  delegate :apply, to: :SpecificNodeMailer

  # Preview this email at http://localhost:3000/rails/mailers/specific_node_mailer/notify_change
  delegate :notify_change, to: :SpecificNodeMailer
end
