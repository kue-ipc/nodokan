require 'set'

class RadiusCheckAllJob < ApplicationJob
  queue_as :default

  def perform
    username_list = []

    # MACアドレス
    mac_address_list = Nic.includes(:network)
      .where(network: {auth: true})
      .where.not(mac_address_data: nil)
      .map(&:mac_address_raw)

    # ユーザー名
    username_list = User.includes(:auth_network)
      .where(auth_network: {auth: true})
      .map(&:username)

    all_list = mac_address_list + username_list

    Radius::Radcheck.where.not(username: all_list).destroy_all
    Radius::Radreply.where.not(username: all_list).destroy_all
    Radius::Radusergroup.where.not(username: all_list).destroy_all
  end
end
