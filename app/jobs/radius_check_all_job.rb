class RadiusCheckAllJob < RadiusJob
  queue_as :default

  def perform
    # MACアドレス
    mac_address_list = Nic.where.not(mac_address_data: nil).where(auth: true)
      .map(&:mac_address_raw)

    # ユーザー名
    username_list =  User.includes(:assignments)
      .where(assignments: {auth: true}).where(deleted: false).map(&:username)

    all_list = mac_address_list + username_list

    Radius::Radcheck.where.not(username: all_list).destroy_all
    Radius::Radreply.where.not(username: all_list).destroy_all
    Radius::Radusergroup.where.not(username: all_list).destroy_all
  end
end
