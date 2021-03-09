require 'set'

class RadiusCheckAllJob < ApplicationJob
  queue_as :default

  def perform
    username_list = []

    # MACアドレス
    mac_address_list = Nic.includes(:network)
      .where(network: {auth: true})
      .where.not(mac_address: nil)
      .map(&:mac_address_raw)

    # ユーザー名
    username_list = User.include(:network)
      .where(network: {auth: true})
      .map(&:username)

    Radius::Radcheck.where.not(username: username_list).destroy_all
    Radius::Radreply.where.not(username: username_list).destroy_all
    Radius::Radusergroup.where.not(username: username_list).destroy_all
  end
end
