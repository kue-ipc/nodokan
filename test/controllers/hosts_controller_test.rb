require "test_helper"

class HostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @node = nodes(:virtual_desktop)
  end

  test "should get new" do
    sign_in users(:staff)
    get new_node_host_url(@node)
    assert_response :success
  end

  test "should create host" do
    sign_in users(:staff)
    post node_host_url(@node), params: {host: {id: nodes(:server).id}}
    assert_response :success
  end

  test "should show host" do
    sign_in users(:staff)
    get node_host_url(@node)
    assert_response :success
  end

  test "should get edit" do
    sign_in users(:staff)
    get edit_node_host_url(@node)
    assert_response :success
  end

  test "should update host" do
    sign_in users(:staff)
    patch node_host_url(@node), params: {host: {id: nodes(:server).id}}
    assert_response :success
  end

  test "should destroy host" do
    sign_in users(:staff)
    delete node_host_url(@node)
    assert_response :success
  end
end
