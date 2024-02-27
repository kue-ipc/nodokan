require "test_helper"

class NodesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @node = nodes(:desktop)
    @other_node = nodes(:other_desktop)
  end

  # index

  test "admin should get index" do
    sign_in users(:admin)
    get nodes_url
    assert_response :success
    assert_select "a[href=\"#{node_path(@node)}\"]"
    assert_select "a[href=\"#{node_path(@other_node)}\"]"
  end

  test "user should get index" do
    sign_in users(:user)
    get nodes_url
    assert_response :success
    assert_select "a[href=\"#{node_path(@node)}\"]"
    assert_select "a[href=\"#{node_path(@other_node)}\"]", false
  end

  test "redirect to login INSTEAD OF get index" do
    get nodes_url
    assert_redirected_to new_user_session_path
  end

  # show

  test "admin should show node" do
    sign_in users(:admin)
    get node_url(@node)
    assert_response :success
  end

  test "user should show node" do
    sign_in users(:user)
    get node_url(@node)
    assert_response :success
  end

  test "other should NOT show" do
    sign_in users(:other)
    get node_url(@node)
    assert_response :not_found
  end

  test "redirect to login INSTEAD OF show node" do
    get node_url(@node)
    assert_redirected_to new_user_session_path
  end

  # new

  test "admin should get new" do
    sign_in users(:admin)
    get new_node_url
    assert_response :success
    assert_select "div#node_nics_attributes_0"
  end

  test "user should get new" do
    sign_in users(:user)
    get new_node_url
    assert_response :success
    assert_select "div#node_nics_attributes_0"
  end

  test "other should get new" do
    sign_in users(:other)
    get new_node_url
    assert_response :success
    assert_select "div#node_nics_attributes_0", false
  end

  test "redirect to login INSTEAD OF get new" do
    get new_node_url
    assert_redirected_to new_user_session_path
  end

  # edit

  test "admin should get edit" do
    sign_in users(:admin)
    get edit_node_url(@node)
    assert_response :success
  end

  # create

  test "admin should create node" do
    sign_in users(:admin)
    assert_difference("Node.count") do
      post nodes_url,
        params: {node: {name: @node.name, note: @node.note, user_id: users(:admin).id}}
    end

    assert_redirected_to node_url(Node.last)
  end

  # update

  test "admin should update node" do
    sign_in users(:admin)
    patch node_url(@node),
      params: {node: {name: @node.name, note: @node.note}}
    assert_redirected_to node_url(@node)
  end

  # destroy

  test "admin should destroy node" do
    sign_in users(:admin)
    assert_difference("Node.count", -1) do
      delete node_url(@node)
    end

    assert_redirected_to nodes_url
  end

  # copy

  # transfer
end
