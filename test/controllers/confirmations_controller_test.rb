require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def confirmation_to_params(confirmation)
    {
      existence: confirmation.existence,
      content: confirmation.content,
      os_update: confirmation.os_update,
      app_update: confirmation.app_update,
      software: confirmation.software,
      security_hardwares: confirmation.security_hardwares,
      security_update: confirmation.security_update,
      security_scan: confirmation.security_scan,
      security_software: {
        os_category: confirmation.security_software&.os_category,
        installation_method: @confirmation.security_software&.installation_method,
        name: @confirmation.security_software&.name,
      },
    }
  end

  setup do
    @confirmation = confirmations(:desktop)
  end

  # admin

  test "admin should create confirmation" do
    sign_in users(:admin)
    other_node = nodes(:other_desktop)
    assert_difference("Confirmation.count") do
      post node_confirmation_url(other_node), params: {confirmation: confirmation_to_params(@confirmation)}
    end
    assert_redirected_to node_url(other_node)
  end

  test "admin should update confirmation" do
    sign_in users(:admin)
    patch node_confirmation_url(@confirmation.node), params: {confirmation: confirmation_to_params(@confirmation)}
    assert_redirected_to node_url(@confirmation.node)
  end

  # user

  test "user should create confirmation" do
    sign_in users(:user)
    other_node = nodes(:other_desktop)
    assert_difference("Confirmation.count") do
      post node_confirmation_url(other_node), params: {confirmation: confirmation_to_params(@confirmation)}
    end
    assert_redirected_to node_url(other_node)
  end

  test "user should update confirmation" do
    sign_in users(:user)
    patch node_confirmation_url(@confirmation.node), params: {confirmation: confirmation_to_params(@confirmation)}
    assert_redirected_to node_url(@confirmation.node)
  end

  test "user should NOT create confirmation for other owner" do
    sign_in users(:user)
    other_node = nodes(:admin_desktop)
    assert_no_difference("Confirmation.count") do
      assert_raises(Pundit::NotAuthorizedError) do
        post node_confirmation_url(other_node), params: {confirmation: confirmation_to_params(@confirmation)}
      end
    end
  end

  # no login

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
