require "test_helper"

class NetworksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @network = networks(:client)
  end

  # index

  test "should get index" do
    sign_in users(:user)
    get networks_url
    assert_response :success
    assert_select "a[href=\"#{network_path(@network)}\"]"
    assert_select "a[href=\"#{network_path(networks(:extra))}\"]", false
  end

  test "admin should get index" do
    sign_in users(:admin)
    get networks_url
    assert_response :success
    assert_select "a[href=\"#{network_path(@network)}\"]"
    assert_select "a[href=\"#{network_path(networks(:extra))}\"]"
  end

  test "less should get index" do
    sign_in users(:less)
    get networks_url
    assert_response :success
    assert_select "a[href=\"#{network_path(@network)}\"]", false
    assert_select "a[href=\"#{network_path(networks(:extra))}\"]", false
  end

  test "guest redirect to login INSTEAD OF get index" do
    get networks_url
    assert_redirected_to new_user_session_path
  end

  # show

  test "should show network" do
    sign_in users(:user)
    get network_url(@network)
    assert_response :success
  end

  test "admin should show network" do
    sign_in users(:admin)
    get network_url(@network)
    assert_response :success
  end

  test "less should NOT show network" do
    sign_in users(:less)
    get network_url(@network)
    assert_response :not_found
  end

  test "guest redirect to login INSTEAD OF show network" do
    get network_url(@network)
    assert_redirected_to new_user_session_path
  end

  # new

  test "should NOT get new" do
    sign_in users(:user)
    get new_network_url
    assert_response :forbidden
  end

  test "admin should get new" do
    sign_in users(:admin)
    get new_network_url
    assert_response :success
  end

  test "guest redirect to login INSTEAD OF get new" do
    get new_network_url
    assert_redirected_to new_user_session_path
  end

  # edit

  test "should NOT get edit" do
    sign_in users(:user)
    get edit_network_url(@network)
    assert_response :forbidden
  end

  test "admin should get edit" do
    sign_in users(:admin)
    get edit_network_url(@network)
    assert_response :success
  end

  test "guest redirect to login INSTEAD OF get edit" do
    get edit_network_url(@network)
    assert_redirected_to new_user_session_path
  end

  # create

  test "should NOT create network" do
    sign_in users(:user)
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {name: "name"}}
    end
    assert_response :forbidden
  end

  test "admin should create network" do
    sign_in users(:admin)
    assert_difference("Network.count") do
      post networks_url, params: {network: {name: "name"}}
    end
    assert_redirected_to network_url(Network.last)
  end

  test "guest redirect to login INSTEAD OF create network" do
    assert_no_difference("Network.count") do
      post networks_url, params: {network: {name: "name"}}
    end
    assert_redirected_to new_user_session_path
  end

  # test 'admin should create network' do
  #   sign_in users(:admin)
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

  # udpate

  test "should NOT update network" do
    sign_in users(:user)
    patch network_url(@network), params: {network: {name: "name"}}
    assert_response :forbidden
  end

  test "admin should update network" do
    sign_in users(:admin)
    patch network_url(@network), params: {network: {name: "name"}}
    assert_redirected_to network_url(@network)
  end

  test "guest redirect to login INSTEAD OF update network" do
    patch network_url(@network), params: {network: {name: "name"}}
    assert_redirected_to new_user_session_path
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

  # destroy

  test "should NOT destroy network" do
    sign_in users(:user)
    assert_no_difference("Network.count") do
      delete network_url(networks(:noip))
    end
    assert_response :forbidden
  end

  test "admin should destroy network" do
    sign_in users(:admin)
    assert_difference("Network.count", -1) do
      delete network_url(networks(:noip))
    end
    assert_redirected_to networks_url
  end

  test "guest redirect to login INSTEAD OF destroy network" do
    assert_no_difference("Network.count") do
      delete network_url(networks(:noip))
    end
    assert_redirected_to new_user_session_path
  end
end
