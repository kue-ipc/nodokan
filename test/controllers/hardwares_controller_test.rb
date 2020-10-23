require 'test_helper'

class HardwaresControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get hardwares_index_url
    assert_response :success
  end

  test "should get edit" do
    get hardwares_edit_url
    assert_response :success
  end

  test "should get update" do
    get hardwares_update_url
    assert_response :success
  end

end
