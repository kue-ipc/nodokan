require "test_helper"

class SecuritySoftwaresControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
  end

  test "should get index" do
    get security_softwares_url
    assert_response :success
  end
end
