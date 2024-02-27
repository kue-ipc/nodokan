require "test_helper"

class ManageControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # admin

  test "admin should get places" do
    sign_in users(:admin)
    get manage_places_url
    assert_response :success
  end

  test "admin should get hardwares" do
    sign_in users(:admin)
    get manage_hardwares_url
    assert_response :success
  end

  test "admin should get operating_systems" do
    sign_in users(:admin)
    get manage_operating_systems_url
    assert_response :success
  end

  test "admin should get security_softwares" do
    sign_in users(:admin)
    get manage_security_softwares_url
    assert_response :success
  end

  test "admin should get device_types" do
    sign_in users(:admin)
    get manage_device_types_url
    assert_response :success
  end

  test "admin should get os_categories" do
    sign_in users(:admin)
    get manage_os_categories_url
    assert_response :success
  end

  # user

  test "user should get places" do
    sign_in users(:user)
    assert_raises(Pundit::NotAuthorizedError) do
      get manage_places_url
    end
  end

  test "user should get hardwares" do
    sign_in users(:user)
    assert_raises(Pundit::NotAuthorizedError) do
      get manage_hardwares_url
    end
  end

  test "user should get operating_systems" do
    sign_in users(:user)
    assert_raises(Pundit::NotAuthorizedError) do
      get manage_operating_systems_url
    end
  end

  test "user should get security_softwares" do
    sign_in users(:user)
    assert_raises(Pundit::NotAuthorizedError) do
      get manage_security_softwares_url
    end
  end

  test "user should get device_types" do
    sign_in users(:user)
    assert_raises(Pundit::NotAuthorizedError) do
      get manage_device_types_url
    end
  end

  test "user should get os_categories" do
    sign_in users(:user)
    assert_raises(Pundit::NotAuthorizedError) do
      get manage_os_categories_url
    end
  end

  # no login

  test "redirect to login INSTEAD OF get places" do
    get manage_places_url
    assert_redirected_to new_user_session_path
  end

  test "redirect to login INSTEAD OF get hardwares" do
    get manage_hardwares_url
    assert_redirected_to new_user_session_path
  end

  test "redirect to login INSTEAD OF get operating_systems" do
    get manage_operating_systems_url
    assert_redirected_to new_user_session_path
  end

  test "redirect to login INSTEAD OF get security_softwares" do
    get manage_security_softwares_url
    assert_redirected_to new_user_session_path
  end

  test "redirect to login INSTEAD OF get device_types" do
    get manage_device_types_url
    assert_redirected_to new_user_session_path
  end

  test "redirect to login INSTEAD OF get os_categories" do
    get manage_os_categories_url
    assert_redirected_to new_user_session_path
  end
end
