require "test_helper"

class PlacesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "admin should get index" do
    sign_in users(:admin)
    get places_url
    assert_response :success
  end

  test "user should get index" do
    sign_in users(:user)
    get places_url
    assert_response :success
  end

  test "redirect to login INSTEAD OF get index" do
    get places_url
    assert_response 401
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
