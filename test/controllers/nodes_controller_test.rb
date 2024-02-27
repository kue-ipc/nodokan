require "test_helper"

class NodesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @node = nodes(:desktop)
  end

  # admin

  test "admin should get index" do
    sign_in users(:admin)
    get nodes_url
    assert_response :success
  end

  test "admin should get new" do
    sign_in users(:admin)
    get new_node_url
    assert_response :success
  end

  test "admin should create node" do
    sign_in users(:admin)
    assert_difference("Node.count") do
      post nodes_url,
        params: {node: {name: @node.name, note: @node.note, user_id: users(:admin).id}}
    end

    assert_redirected_to node_url(Node.last)
  end

  test "admin should show node" do
    sign_in users(:admin)
    get node_url(@node)
    assert_response :success
  end

  test "admin should get edit" do
    sign_in users(:admin)
    get edit_node_url(@node)
    assert_response :success
  end

  test "admin should update node" do
    sign_in users(:admin)
    patch node_url(@node),
      params: {node: {name: @node.name, note: @node.note}}
    assert_redirected_to node_url(@node)
  end

  test "admin should destroy node" do
    sign_in users(:admin)
    assert_difference("Node.count", -1) do
      delete node_url(@node)
    end

    assert_redirected_to nodes_url
  end
end
