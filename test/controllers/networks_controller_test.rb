require "test_helper"

class NetworksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @network = networks(:client)
  end

  test "should get index" do
    get networks_url
    assert_response :success
  end

  test "should get new" do
    get new_network_url
    assert_response :success
  end

  # test 'should create network' do
  #   assert_difference('Network.count') do
  #     post networks_url,
  #       params: { network: {
  #         auth: @network.auth, closed: @network.closed, dhcp: @network.dhcp,
  #         ipv6_address: @network.ipv6_address, ipv6_gateway: @network.ipv6_gateway,
  #         ipv6_prefix: @network.ipv6_prefix,
  #         ipv4_address: @network.ipv4_address, ipv4_gateway: @network.ipv4_gateway, ipv4_mask: @network.ipv4_mask,
  #         name: @network.name, vlan: @network.vlan,
  #       } }
  #   end
  #   assert_redirected_to network_url(Network.last)
  # end

  test "should show network" do
    get network_url(@network)
    assert_response :success
  end

  test "should get edit" do
    get edit_network_url(@network)
    assert_response :success
  end

  # test 'should update network' do
  #   patch network_url(@network),
  #     params: { network: {
  #       auth: @network.auth, closed: @network.closed, dhcp: @network.dhcp,
  #       ipv6_address: @network.ipv6_address, ipv6_gateway: @network.ipv6_gateway,
  #       ipv6_prefix: @network.ipv6_prefix,
  #       ipv4_address: @network.ipv4_address, ipv4_gateway: @network.ipv4_gateway, ipv4_mask: @network.ipv4_mask,
  #       name: @network.name, vlan: @network.vlan,
  #     } }
  #   assert_redirected_to network_url(@network)
  # end

  # test 'should destroy network' do
  #   assert_difference('Network.count', -1) do
  #     delete network_url(@network)
  #   end

  #   assert_redirected_to networks_url
  # end
end
