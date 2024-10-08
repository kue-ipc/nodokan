class RadiusUserDelJob < RadiusJob
  queue_as :default

  def perform(username)
    # Auth-Typeを削除
    Radius::Radcheck.destroy_by(username:)
    # VLANを削除
    Radius::Radreply.destroy_by(username:)
    # グループを設定
    Radius::Radusergroup.destroy_by(username:)
  end
end
