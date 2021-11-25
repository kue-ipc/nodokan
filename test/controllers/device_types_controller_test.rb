require "test_helper"

class DeviceTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @device_type = device_types(:pc)
  end

  test "should get index" do
    get device_types_url
    assert_response :success
  end

  test "should get show" do
    get device_type_url(@device_type)
    assert_response :success
  end

  # test "should get create" do
  #   get device_types_create_url
  #   assert_response :success
  # end

  # test "should get update" do
  #   get device_types_update_url
  #   assert_response :success
  # end

  # test "should get destroy" do
  #   get device_types_destroy_url
  #   assert_response :success
  # end
end
