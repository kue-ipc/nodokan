require "test_helper"

class AdminMailerTest < ActionMailer::TestCase
  test "job_failure" do
    mail = AdminMailer.with(job: "job", job_id: "job_id", time: "time",
      exception: "exception").job_failure
    assert_equal "ジョブ失敗 - のどかん", mail.subject
    assert_equal ["admin@example.jp"], mail.to
    assert_nil mail.from

    assert_equal <<~MESSAGE, mail.body.encoded.gsub(/\R/, "\n")
      端末管理システムで、下記のジョブが失敗しました。

      Job: job
      Job ID: job_id
      Time: time
      Exception: exception

      ---
      このメールの送信者は送信専用です。そのまま返信しないでください。
      メール内容のお問い合わせは下記管理者宛までお願いします。
        管理者 admin@example.jp

      - のどかん -
    MESSAGE
  end
end
