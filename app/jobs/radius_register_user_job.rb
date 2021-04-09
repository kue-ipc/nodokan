class RadiusRegisterUserJob < ApplicationJob
  queue_as :default

  def perform(username, vlan)
    if username =~ /\A[0-9a-f]{12}\z/
      logger.error("MACアドレスと同じ形式のユーザー名は処理で来ません: #{username}")
      return
    end

    # Auth-Typeを設定
    Radius::Radcheck.find_or_initialize_by(username: username)
      .tap do |radcheck|
      radcheck.attr = 'Auth-Type'
      radcheck.op = ':='
      radcheck.value = 'LDAP'
      radcheck.save!
    end

    # VLANを設定
    Radius::Radreply.find_or_initialize_by(username: username)
      .tap do |radreply|
      radreply.attr = 'Tunnel-Private-Group-Id'
      radreply.op = ':='
      radreply.value = vlan.to_s
      radreply.save!
    end

    # グループを設定
    Radius::Radusergroup.find_or_initialize_by(username: username)
      .tap do |radusergroup|
      radusergroup.groupname = 'user'
      radusergroup.priority = 1
      radusergroup.save!
    end

    logger.info("ユーザーを登録しました。: #{username} - #{vlan}")
  end
end
