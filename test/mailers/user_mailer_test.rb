require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "notice_nodes" do
    mail = UserMailer.notice_nodes
    assert_equal "Notice nodes", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "apply_specific_node" do
    mail = UserMailer.apply_specific_node
    assert_equal "Apply specific node", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
