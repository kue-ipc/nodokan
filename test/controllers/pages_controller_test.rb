require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # root

  test "admin should get root" do
    sign_in users(:admin)
    get root_url
    assert_response :success
    assert_select "a", "admin"
    assert_select "a", "管理"
  end

  test "user should get root" do
    sign_in users(:user)
    get root_url
    assert_response :success
    assert_select "a", "user"
  end

  test "get root with login" do
    get root_url
    assert_response :success
    assert_select "form"
  end

  # about

  test "admin should get about" do
    sign_in users(:admin)
    get about_url
    assert_response :success
  end

  test "user should get about" do
    sign_in users(:user)
    get about_url
    assert_response :success
  end

  test "should get about" do
    get about_url
    assert_response :success
  end
end
