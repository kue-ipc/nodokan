require "test_helper"
require_relative "confirmations_controller_test"

class ConfirmationsControllerUserTest < ConfirmationsControllerTest
  include SignInUser
  test "should create confirmation" do
    other_node = nodes(:other_desktop)
    assert_difference("Confirmation.count") do
      post node_confirmation_url(other_node), params: {confirmation: confirmation_to_params(@confirmation)}
    end
    assert_redirected_to node_url(other_node)
  end

  test "should update confirmation" do
    patch node_confirmation_url(@confirmation.node), params: {confirmation: confirmation_to_params(@confirmation)}
    assert_redirected_to node_url(@confirmation.node)
  end

  test "should NOT create confirmation for other owner" do
    other_node = nodes(:admin_desktop)
    assert_no_difference("Confirmation.count") do
      assert_raises(Pundit::NotAuthorizedError) do
        post node_confirmation_url(other_node), params: {confirmation: confirmation_to_params(@confirmation)}
      end
    end
  end
end
