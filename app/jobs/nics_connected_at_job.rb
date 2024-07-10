# 全てのNICについて接続日を更新する。
# TODO: 更新中に削除された場合は、よくわからない。
# NOTE: ジョブを分割すると遅くなるので、してはいけない。

class NicsConnectedAtJob < ApplicationJob
  queue_as :default

  def perform
    Nic.find_each do |nic|
      update_time(nic)
    end
  end

  def update_time(nic)
    attributes = [
      :ipv4_resolved_at, :ipv6_discovered_at,
      :ipv4_leased_at, :ipv6_leased_at,
      :auth_at,
    ].map { |name|
      time = __send__(name, nic)
      [name, time] if time != nic.__send__(name)
    }.compact.to_h

    return if attributes.blank?

    # no verify nor callback nor versioning
    nic.update_columns(attributes)
  end

  def ipv4_resolved_at(nic)
    if nic.has_mac_address?
      Ipv4Arp.where(mac_address_data: nic.mac_address_data)
        .order(resolved_at: :desc).pick(:resolved_at)
    elsif nic.has_ipv4?
      Ipv4Arp.where(ipv4_data: nic.ipv4_data)
        .order(resolved_at: :desc).pick(:resolved_at)
    end
  end

  def ipv6_discovered_at(nic)
    if nic.has_mac_address?
      Ipv6Neighbor.where(mac_address_data: nic.mac_address_data)
        .order(discovered_at: :desc).pick(:discovered_at)
    elsif nic.has_ipv6?
      Ipv6Neighbor.where(ipv6_data: nic.ipv6_data)
        .order(discovered_at: :desc).pick(:discovered_at)
    end
  end

  def ipv4_leased_at(nic)
    return unless nic.has_mac_address? && nic.network_id

    Kea::Lease4.where(hwaddr: nic.mac_address_data, subnet_id: nic.network_id)
      .order(expire: :desc).pick(:expire, :valid_lifetime)
      &.then { |expire, valid_lifetime| expire - valid_lifetime }
  end

  def ipv6_leased_at(nic)
    return unless nic.node.has_duid? && nic.network_id

    Kea::Lease6.where(duid: nic.node.duid_data, subnet_id: nic.network_id)
      .order(expire: :desc).pick(:expire, :valid_lifetime)
      &.then { |expire, valid_lifetime| expire - valid_lifetime }
  end

  def acct_at(nic)
    return unless nic.has_mac_address?

    Radius::Radacct.where(username: nic.mac_address_raw)
      .order(acctupdatetime: :desc).pick(:acctupdatetime)
  end

  def auth_at(nic)
    return unless nic.has_mac_address?

    Radius::Radpostauth
      .where(username: nic.mac_address_raw, reply: "Access-Accept")
      .order(authdate: :desc).pick(:authdate)
  end
end
