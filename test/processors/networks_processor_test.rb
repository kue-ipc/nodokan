require "test_helper"

class NetworksProcessorTest < ActiveSupport::TestCase
  def network_to_params(network)
    {
      name: network.name,
      vlan: network.vlan,
      domain: network.domain,
      domain_search: network.domain_search_data,
      flag: network.flag,
      ra: network.ra,
      ipv4_network: network.ipv4_network_cidr,
      ipv4_gateway: network.ipv4_gateway_address,
      ipv4_dns_servers: network.ipv4_dns_servers_data,
      ipv4_pools: network.ipv4_pools.map(&:identifier),
      ipv6_network: network.ipv6_network_cidr,
      ipv6_gateway: network.ipv6_gateway_address,
      ipv6_dns_servers: network.ipv6_dns_servers_data,
      ipv6_pools: network.ipv6_pools.map(&:identifier),
      note: network.note,
    }
  end

  setup do
    @user = users(:user)
    @processor = NetworksProcessor.new(@user)
    @network = networks(:network)
  end

  test "serialize network" do
    assert_equal network_to_params(@network), @processor.serialize(@network)
  end

  test "idx" do
    ids = @processor.ids

    assert_equal [@network.id], ids
  end

  # network

  test "index networks" do
    networks = @processor.index

    assert_equal [@network], networks
  end

  test "show network" do
    assert_equal @network.name, @processor.show(@network.id)[:name]

    assert_raise Pundit::NotAuthorizedError do
      @processor.show(networks(:server).id)
    end
  end

  test "create network" do
    params = network_to_params(@network)
    assert_raise Pundit::NotAuthorizedError do
      @processor.create(params)
    end
  end

  test "update network" do
    params = network_to_params(@network)
    assert_raise Pundit::NotAuthorizedError do
      @processor.update(@network.id, params)
    end
  end

  test "desroy network" do
    assert_raise Pundit::NotAuthorizedError do
      @processor.destroy(@network.id)
    end
  end

  # admin

  test "admin: index networks" do
    @processor = NetworksProcessor.new(users(:admin))
    networks = @processor.index

    assert_includes networks, @network
  end

  test "admin: create network" do
    @processor = NetworksProcessor.new(users(:admin))
    params = network_to_params(@network)
    params.merge!({
      name: "New Network",
      vlan: 2,
      ipv4_network: "192.168.42.0/24",
      ipv4_gateway: "192.168.42.254",
      ipv4_pools: ["d[192.168.42.1-192.168.42.10]"],
      ipv6_network: "fd00:42::/64",
      ipv6_gateway: "fd00:42::1",
      ipv6_pools: ["s[fd00:42::2-fd00:42::10]"],
    })
    # assert_equal "", params
    assert_difference("Network.count") do
      @processor.create(params)
    end
  end

  test "admin: update network" do
    @processor = NetworksProcessor.new(users(:admin))
    params = network_to_params(@network)
    params.merge!({
      vlan: 2,
      ipv4_network: "192.168.42.0/24",
      ipv4_gateway: "192.168.42.254",
      ipv4_pools: ["d[192.168.42.1-192.168.42.10]"],
      ipv6_network: "fd00:42::/64",
      ipv6_gateway: "fd00:42::1",
      ipv6_pools: ["s[fd00:42::2-fd00:42::10]"],
    })
    assert_no_difference("Network.count") do
      @processor.update(@network.id, params)
    end
    @network.reload
  end

  test "admin: desroy network" do
    @processor = NetworksProcessor.new(users(:admin))
    assert_difference("Network.count", -1) do
      @processor.destroy(@network.id)
    end
  end
end
