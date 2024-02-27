require "test_helper"

class SecuritySoftwaresControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "admin should get index" do
    sign_in users(:admin)
    get security_softwares_url
    assert_response :success
  end
end
