require "test_helper"

class OperatingSystemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "admin should get index" do
    sign_in users(:admin)
    get operating_systems_url
    assert_response :success
  end
end
