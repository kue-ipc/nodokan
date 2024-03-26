require "test_helper"

class ComponentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @node = nodes(:cluster)
  end

  test "should get index" do
    sign_in users(:user)
    get node_components_url(@node)
    assert_response :success
  end

  test "should get new" do
    sign_in users(:user)
    get new_node_component_url(@node)
    assert_response :success
  end

  test "should show component" do
    sign_in users(:user)
    get node_component_url(@node.components.first, node_id: @node.id)
    assert_response :success
  end

  test "should update component" do
    sign_in users(:user)
    put node_component_url(@node.components.first, node_id: @node.id),
      as: :turbo_stream
    assert_response :success
  end

  test "should destroy component" do
    sign_in users(:user)
    delete node_component_url(@node.components.first, node_id: @node.id),
      as: :turbo_stream
    assert_response :success
  end
end
