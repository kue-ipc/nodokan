require "test_helper"

class Ipv6PoolsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should NOT get new" do
    sign_in users(:user)
    assert_raises(Pundit::NotAuthorizedError) do
      get new_ipv6_pool_url
    end
  end

  test "admin should get new" do
    sign_in users(:admin)
    get new_ipv6_pool_url
    assert_response :success
  end

  test "guest redirect to login INSTEAD OF get new" do
    get new_ipv6_pool_url
    assert_redirected_to new_user_session_path
  end
end
