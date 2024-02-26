require "test_helper"
require_relative "confirmations_controller_test"

class ConfirmationsControllerGuestTest < ConfirmationsControllerTest
  test "redirect to login INSTEAD OF create confirmation" do
    other_node = nodes(:other_desktop)
    assert_no_difference("Confirmation.count") do
      post node_confirmation_url(other_node), params: {confirmation: confirmation_to_params(@confirmation)}
    end
    assert_redirected_to new_user_session_path
  end

  test "redirect to login INSTEAD OF update confirmation" do
    patch node_confirmation_url(@confirmation.node), params: {confirmation: confirmation_to_params(@confirmation)}
    assert_redirected_to new_user_session_path
  end
end
