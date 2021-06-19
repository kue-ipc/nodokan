require 'test_helper'

class PlacesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  class SignInAdmin < PlacesControllerTest
    setup do
      sign_in users(:admin)
    end

    test 'should get index' do
      get places_url
      assert_response :success
    end

    # test "should get edit" do
    #   get places_edit_url
    #   assert_response :success
    # end

    # test "should get update" do
    #   get places_update_url
    #   assert_response :success
    # end

    # test "should get merge" do
    #   get places_merge_url
    #   assert_response :success
    # end
  end

  class SignInUser < PlacesControllerTest
    setup do
      sign_in users(:user)
    end
    test 'should get index' do
      get places_url
      assert_response :success
    end

    # test "should get edit" do
    #   get places_edit_url
    #   assert_response :success
    # end

    # test "should get update" do
    #   get places_update_url
    #   assert_response :success
    # end

    # test "should get merge" do
    #   get places_merge_url
    #   assert_response :success
    # end
  end

  class Anonymous < PlacesControllerTest
    test 'redirect to login INSTEAD OF get index' do
      get places_url
      assert_redirected_to new_user_session_path
    end
  end
end
