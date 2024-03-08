require "test_helper"

class Ipv4PoolsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get ipv4_pools_new_url
    assert_response :success
  end
end
