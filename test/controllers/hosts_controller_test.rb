require "test_helper"

class HostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @node = nodes(:virtual_desktop)
  end

  test "should get new" do
    sign_in users(:user)
    get new_node_host_url(@node)
    assert_response :success
  end

  test "should create host" do
    sign_in users(:user)
    post node_host_url(@node), params: {host: {id: nodes(:server).id}}
    assert_response :success
  end

  test "should show host" do
    sign_in users(:user)
    get node_host_url(@node)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:user)
    get edit_node_host_url(@node)
    assert_response :success
  end

  test "should update host" do
    sign_in users(:user)
    patch node_host_url(@node), params: {host: {id: nodes(:server).id}}
    assert_response :success
  end

  test "should destroy host" do
    sign_in users(:user)
    delete node_host_url(@node)
    assert_response :success
  end
end
