require "test_helper"

class AdminMailerTest < ActionMailer::TestCase
  test "job_failure" do
    mail = AdminMailer.with(job: "job", job_id: "job_id", time: "time",
      exception: "exception").job_failure
    assert_equal "【端末管理システム管理通知】ジョブ失敗", mail.subject
    assert_equal ["admin@example.jp"], mail.to
    assert_equal ["no-reply@example.jp"], mail.from

    assert_equal <<~MESSAGE.gsub(/\R/, "\r\n"), mail.body.encoded
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
