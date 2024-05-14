require "test_helper"

class KeaSubnet4AddJobTest < ActiveJob::TestCase
  setup do
    Kea::Dhcp4Subnet.transaction do
      Kea::Dhcp4Subnet.dhcp4_audit
      Kea::Dhcp4Subnet.destroy_all
    end

    @network = networks(:client)
  end

  test "add subnet" do
    assert_difference("Kea::Dhcp4Subnet.count") do
      perform_enqueued_jobs do
        KeaSubnet4AddJob.perform_later(
          @network.id,
          @network.ipv4_network,
          {routers: @network.ipv4_gateway},
          @network.ipv4_pools.where(ipv4_config: "dynamic").map(&:ipv4_range))
      end
    end
    subnet = Kea::Dhcp4Subnet.last
    assert_equal @network.id, subnet.subnet_id
    assert_equal @network.ipv4_network_cidr, subnet.subnet_prefix
    assert_equal [Kea::Dhcp4Server.default], subnet.dhcp4_servers
    assert_equal 1, subnet.dhcp4_options.count
    assert_equal @network.ipv4_pools.where(ipv4_config: "dynamic").count,
      subnet.dhcp4_pools.count
  end

  test "add subnet update" do
    perform_enqueued_jobs do
      KeaSubnet4AddJob.perform_later(
        @network.id,
        @network.ipv4_network,
        {routers: @network.ipv4_gateway},
        @network.ipv4_pools.where(ipv4_config: "dynamic").map(&:ipv4_range))
    end

    assert_no_difference("Kea::Dhcp4Subnet.count") do
      perform_enqueued_jobs do
        KeaSubnet4AddJob.perform_later(
          @network.id,
          IPAddr.new("172.16.1.0/24"),
          {routers: nil},
          [])
      end
    end
    subnet = Kea::Dhcp4Subnet.last
    assert_equal @network.id, subnet.subnet_id
    assert_equal "172.16.1.0/24", subnet.subnet_prefix
    assert_equal [Kea::Dhcp4Server.default], subnet.dhcp4_servers
    assert_equal 0, subnet.dhcp4_options.count
    assert_equal 0, subnet.dhcp4_pools.count
  end
end
