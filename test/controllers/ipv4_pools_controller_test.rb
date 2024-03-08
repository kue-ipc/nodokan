require "test_helper"

class Ipv4PoolsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should NOT get new" do
    sign_in users(:user)
    assert_raises(Pundit::NotAuthorizedError) do
      get new_ipv4_pool_url, as: :turbo_stream
    end
  end

  test "admin should get new" do
    sign_in users(:admin)
    get new_ipv4_pool_url, as: :turbo_stream
    assert_response :success
  end

  test "guest redirect to login INSTEAD OF get new" do
    get new_ipv4_pool_url, as: :turbo_stream
    assert_redirected_to new_user_session_path
  end
end
