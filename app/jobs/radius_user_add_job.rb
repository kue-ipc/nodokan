class RadiusUserAddJob < ApplicationJob
  queue_as :default

  def perform(username, vlan)
    if username =~ /\A[0-9a-f]{12}\z/
      logger.error(t('messages.job.invalid_username') + ": #{username}")
      return
    end

    # Auth-Typeを設定
    Radius::Radcheck.transaction do
      radcheck = Radius::Radcheck.find_or_initialize_by(username: username)
      radcheck.attr = 'Auth-Type'
      radcheck.op = ':='
      radcheck.value = 'LDAP'
      radcheck.save!
    end

    # VLANを設定
    Radius::Radreply.transaction do
      radreply = Radius::Radreply.find_or_initialize_by(username: username)
      radreply.attr = 'Tunnel-Private-Group-Id'
      radreply.op = ':='
      radreply.value = vlan.to_s
      radreply.save!
    end

    # グループを設定
    Radius::Radusergroup.transaction do
      radusergroup = Radius::Radusergroup.find_or_initialize_by(username: username)
      radusergroup.groupname = 'user'
      radusergroup.priority = 1
      radusergroup.save!
    end

    logger.info(t('messages.job.radius_user_del') + ": #{username} - #{vlan}")
  end
end
