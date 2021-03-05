class UserRegistAuthJob < ApplicationJob
  queue_as :default

  def perform(user)
    unless user.auth_network&.auth
      logger.debug('ユーザーは認証ネットワークを持っていません。')
      return
    end

    username = user.username

    # VLANを設定
    radreply = Radius::Radreply.find_or_initialize_by(username: username)
    radreply.attr = 'Tunnel-Private-Group-Id'
    radreply.op = ':='
    radreply.value = user.auth_network.vlan.to_s
    radreply.save

    # グループを設定
    radusergroup =
      Radius::Radusergroup.find_or_initialize_by(username: username)
    radusergroup.groupname = 'user'
    radusergroup.priority = 1
    radusergroup.save
  end
end
