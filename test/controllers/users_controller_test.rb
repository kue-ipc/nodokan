require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  class SignInAdmin < PlacesControllerTest
    setup do
      sign_in users(:admin)
    end

    test "should get index" do
      get users_url
      assert_response :success
    end

    # test "should get show" do
    #   get users_show_url
    #   assert_response :success
    # end

    # test "should get update" do
    #   get users_update_url
    #   assert_response :success
    # end

    # test "should get sync" do
    #   get users_sync_url
    #   assert_response :success
    # end
  end
end
