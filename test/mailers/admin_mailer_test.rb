require "test_helper"

class AdminMailerTest < ActionMailer::TestCase
  test "job_failure" do
    mail = AdminMailer.with(job: "job", job_id: "job_id", time: "time",
      exception: "exception").job_failure
    assert_equal "ジョブ失敗 - 端末管理システム(test)", mail.subject
    assert_equal ["no-reply@example.jp"], mail.from
    assert_equal ["admin@example.jp"], mail.to

    assert_equal <<~MESSAGE, mail.body.encoded.gsub(/\R/, "\n")
      端末管理システムで、下記のジョブが失敗しました。

      ジョブ: job
      ジョブ ID: job_id
      実行日時: time
      例外メッセージ: exception

      ----------------------------------------------------------------------------
      このメールの送信者は送信専用です。そのまま返信しないでください。
      メール内容のお問い合わせは下記宛にお願いします。

        管理者 admin@example.jp

      - 端末管理システム(test) -
    MESSAGE
  end
end
