class RadiusUnregisterUserJob < ApplicationJob
  queue_as :default

  def perform(username)
    if username =~ /\A[0-9a-f]{12}\z/
      logger.error("MACアドレスと同じ形式のユーザー名は処理で来ません: #{username}")
      return
    end

    # Auth-Typeを削除
    Radius::Radcheck.destroy_by(username: username)

    # VLANを削除
    Radius::Radreply.destroy_by(username: username)

    # グループを設定
    Radius::Radusergroup.destroy_by(username: username)

    logger.info("ユーザーを削除しました。: #{username}")
  end
end
