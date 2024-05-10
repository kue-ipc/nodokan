require "set"

class KeaReservationCheckAllJob < ApplicationJob
  queue_as :default

  def perform
    check_reservation4
    check_reservation6
  end

  def check_reservation4
    host_hash = Kea::Host
      .where(dhcp_identifier_type: Kea::HostIdentifierType.hw_address)
      .where.not(dhcp4_subnet_id: nil)
      .to_h { |host| [[host.dhcp4_subnet_id, host.dhcp_identifier], host.ipv4] }

    Nic.includes(:network)
      .where.not(mac_address_data: nil)
      .where.not(ipv4_data: nil)
      .where(ipv4_config: :reserved)
      .where(network: {dhcp: true})
      .find_each do |nic|
        key = [nic.network.id, nic.mac_address_data]
        host_ip = host_hash.delete(key)
        nic.kea_reservation4 if nic.ipv4 != host_ip
      end

    host_hash.each_key do |key|
      KeaReservation4DelJob.perform_later(*key)
    end
  end

  def check_reservation6
    host_hash = Kea::Ipv6Reservation.includes(:host)
      .where(host: {dhcp_identifier_type: Kea::HostIdentifierType.duid})
      .where.not(host: {dhcp6_subnet_id: nil})
      .to_h { |r| [[r.host.dhcp6_subnet_id, r.host.dhcp_identifier], r.ipv6] }

    Nic.includes(:node, :network)
      .where.not(node: {duid_data: nil})
      .where.not(ipv6_data: nil)
      .where(ipv6_config: :reserved)
      .where(network: {ra: ["managed", "assist"]})
      .find_each do |nic|
        key = [nic.network.id, nic.node.duid_data]
        host_ip = host_hash.delete(key)
        nic.kea_reservation6 if nic.ipv6 != host_ip
      end

    host_hash.each_key do |key|
      KeaReservation6DelJob.perform_later(*key)
    end
  end

  def clean_reservation
    # サブネットがない場合は削除する。
    Kea::Host
      .where(dhcp4_subnet_id: nil)
      .where(dhcp6_subnet_id: nil)
      .destory_all
  end
end
