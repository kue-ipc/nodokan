require 'test_helper'

class NetworkUsersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get network_users_create_url
    assert_response :success
  end

  test "should get update" do
    get network_users_update_url
    assert_response :success
  end

  test "should get destroy" do
    get network_users_destroy_url
    assert_response :success
  end

  test "should get show" do
    get network_users_show_url
    assert_response :success
  end

end
