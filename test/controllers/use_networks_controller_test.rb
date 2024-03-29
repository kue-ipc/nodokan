require "test_helper"

class UseNetworksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @assignment = assignments(:user_client)
  end

  # test "should get create" do
  #   get use_networks_create_url
  #   assert_response :success
  # end

  # test "should get update" do
  #   get use_networks_update_url
  #   assert_response :success
  # end

  test "admin should get destroy" do
    sign_in users(:admin)
    delete user_use_network_url(@assignment.user, @assignment.network)
    assert_redirected_to user_url(@assignment.user)
  end
end
