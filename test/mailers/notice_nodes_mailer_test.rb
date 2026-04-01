require "test_helper"

class NoticeNodesMailerTest < ActionMailer::TestCase
  def setup
    @user = users(:staff)
    @nodes = [nodes(:desktop)]
  end
  # TODO: まだ書いていない
  # test "user" do
  #   mail = NoticeNodesMailer.user
  #   assert_equal "User", mail.subject
  #   assert_equal [ "to@example.org" ], mail.to
  #   assert_equal [ "from@example.com" ], mail.from
  #   assert_match "Hi", mail.body.encoded
  # end

  # test "deleted_users" do
  #   mail = NoticeNodesMailer.deleted_users
  #   assert_equal "Deleted users", mail.subject
  #   assert_equal [ "to@example.org" ], mail.to
  #   assert_equal [ "from@example.com" ], mail.from
  #   assert_match "Hi", mail.body.encoded
  # end

  test "unowned" do
    mail = NoticeNodesMailer.with(nodes: [nodes(:desktop)]).unowned
    assert_equal "所有者なしの端末 - 端末管理システム(test)", mail.subject
    assert_equal ["no-reply@example.jp"], mail.from
    assert_equal ["admin@example.jp"], mail.to
    assert_equal <<~MESSAGE, mail.body.encoded.gsub(/\R/, "\n")
      下記の端末は、所有者が設定されていません。
      所有者なしの端末に対して、自動化処理や通知が行われません。
      ※ ユーザーが削除されても、所有者なしの端末として残ります。

      新たな所有者を割り当てるか、削除を行ってください。

      対象端末: 1 台

      端末 ID: 157353380
      端末名: デスクトップパソコン
      FQDN: desktop.clients.example.jp
      IPv4アドレス: 192.168.2.31
      IPv6アドレス: fd00:2::3:0:1
      MACアドレス: 00-11-22-33-44-55
      リンク: http://nodokan.example.jp/nodes/157353380


      ----------------------------------------------------------------------------
      このメールの送信者は送信専用です。そのまま返信しないでください。
      メール内容のお問い合わせは下記宛にお願いします。

        管理者 admin@example.jp

      - 端末管理システム(test) -
    MESSAGE
  end
end
