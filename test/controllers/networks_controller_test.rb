require "test_helper"

class NetworksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @network = networks(:client)
  end

  # admin

  test "admin should get index" do
    sign_in users(:admin)
    get networks_url
    assert_response :success
  end

  test "admin should get new" do
    sign_in users(:admin)
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

  test "admin should show network" do
    sign_in users(:admin)
    get network_url(@network)
    assert_response :success
  end

  test "admin should get edit" do
    sign_in users(:admin)
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

  # user

  # no login
end
