# Preview all emails at http://localhost:3000/rails/mailers/specific_node_mailer
class SpecificNodeMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/specific_node_mailer/apply
  def apply
    SpecificNodeMailer
    .with(specific_node_application: {
      user_id: User.last.id,
      node_id: Node.first.id,
      action: "register",
      reason: "理由の例",
      rule_set: 1,
      rule_list: "ルールの例\n二行目\n",
      external: "none",
      register_dns: true,
      fqdn: "test.example.jp",
      note: "備考の例\n二行目\n",
    }).apply
  end
end
