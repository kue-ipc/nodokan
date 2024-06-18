require "test_helper"

class KeaSubnet6AddJobTest < ActiveJob::TestCase
  setup do
    Kea::Dhcp6Subnet.transaction do
      Kea::Dhcp6Subnet.dhcp6_audit(cascade_transaction: true)
      Kea::Dhcp6Subnet.destroy_all
    end

    @network = networks(:client)
  end

  test "add subnet" do
    assert_difference("Kea::Dhcp6Subnet.count") do
      perform_enqueued_jobs do
        KeaSubnet6AddJob.perform_later(
          @network.id,
          @network.ipv6_network,
          {},
          @network.ipv6_pools.where(ipv6_config: "dynamic").map(&:ipv6_range))
      end
    end
    subnet = Kea::Dhcp6Subnet.last
    assert_equal @network.id, subnet.subnet_id
    assert_equal @network.ipv6_network_cidr, subnet.subnet_prefix
    assert_equal [Kea::Dhcp6Server.default], subnet.dhcp6_servers
    assert_equal 0, subnet.dhcp6_options.count
    assert_equal @network.ipv6_pools.where(ipv6_config: "dynamic").count,
      subnet.dhcp6_pools.count
  end

  test "add subnet update" do
    perform_enqueued_jobs do
      KeaSubnet6AddJob.perform_later(
        @network.id,
        @network.ipv6_network,
        {},
        @network.ipv6_pools.where(ipv6_config: "dynamic").map(&:ipv6_range))
    end

    assert_no_difference("Kea::Dhcp6Subnet.count") do
      perform_enqueued_jobs do
        KeaSubnet6AddJob.perform_later(
          @network.id,
          IPAddr.new("fd11:22:33:44::/64"),
          {dns_servers: ["fd00:1::1", "fd00:1::2"]},
          [])
      end
    end
    subnet = Kea::Dhcp6Subnet.last
    assert_equal @network.id, subnet.subnet_id
    assert_equal "fd11:22:33:44::/64", subnet.subnet_prefix
    assert_equal [Kea::Dhcp6Server.default], subnet.dhcp6_servers
    assert_equal 1, subnet.dhcp6_options.count
    assert_equal 0, subnet.dhcp6_pools.count
  end
end
