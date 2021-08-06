require "test_helper"

class ManageControllerTest < ActionDispatch::IntegrationTest
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
end
