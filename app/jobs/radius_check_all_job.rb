class RadiusCheckAllJob < RadiusJob
  queue_as :default

  def perform
    # MACアドレス
    mac_address_list = Nic.where.not(mac_address_data: nil).where(auth: true)
      .pluck(:mac_address_data)
      .map { |data| Nic.hex_data_to_str(data, char_case: :lower, sep: "") }

    # ユーザー名
    username_list =  User.includes(:assignments)
      .where(assignments: {auth: true}).where(deleted: false).pluck(:username)

    all_list = mac_address_list + username_list

    Radius::Radcheck.where.not(username: all_list).destroy_all
    Radius::Radreply.where.not(username: all_list).destroy_all
    Radius::Radusergroup.where.not(username: all_list).destroy_all

    # TODO: RADIUS側にレコードがなかった場合に追加する処理の追加
  end
end
