require "test_helper"

class ManageControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  class SignInAdmin < ManageControllerTest
    setup do
      sign_in users(:admin)
    end

    test "should get places" do
      get manage_places_url
      assert_response :success
    end

    test "should get hardwares" do
      get manage_hardwares_url
      assert_response :success
    end

    test "should get operating_systems" do
      get manage_operating_systems_url
      assert_response :success
    end

    test "should get security_softwares" do
      get manage_security_softwares_url
      assert_response :success
    end

    test "should get device_types" do
      get manage_device_types_url
      assert_response :success
    end

    test "should get os_categories" do
      get manage_os_categories_url
      assert_response :success
    end
  end

  class SignInUser < ManageControllerTest
    setup do
      sign_in users(:user)
    end

    test "should get places" do
      assert_raises(Pundit::NotAuthorizedError) do
        get manage_places_url
      end
    end

    test "should get hardwares" do
      assert_raises(Pundit::NotAuthorizedError) do
        get manage_hardwares_url
      end
    end

    test "should get operating_systems" do
      assert_raises(Pundit::NotAuthorizedError) do
        get manage_operating_systems_url
      end
    end

    test "should get security_softwares" do
      assert_raises(Pundit::NotAuthorizedError) do
        get manage_security_softwares_url
      end
    end

    test "should get device_types" do
      assert_raises(Pundit::NotAuthorizedError) do
        get manage_device_types_url
      end
    end

    test "should get os_categories" do
      assert_raises(Pundit::NotAuthorizedError) do
        get manage_os_categories_url
      end
    end
  end

  class Anonymous < ManageControllerTest
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
end
