require "test_helper"

class DeviceTypesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get device_types_index_url
    assert_response :success
  end

  test "should get show" do
    get device_types_show_url
    assert_response :success
  end

  test "should get create" do
    get device_types_create_url
    assert_response :success
  end

  test "should get update" do
    get device_types_update_url
    assert_response :success
  end

  test "should get destroy" do
    get device_types_destroy_url
    assert_response :success
  end
end
