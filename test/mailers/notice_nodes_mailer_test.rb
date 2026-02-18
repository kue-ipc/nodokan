require "test_helper"

class NoticeNodesMailerTest < ActionMailer::TestCase
  test "user" do
    mail = NoticeNodesMailer.user
    assert_equal "User", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "deleted_users" do
    mail = NoticeNodesMailer.deleted_users
    assert_equal "Deleted users", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "unowned" do
    mail = NoticeNodesMailer.unowned
    assert_equal "Unowned", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
