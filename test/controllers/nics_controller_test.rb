require "test_helper"

class NicsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @nic = nodes(:desktop)
  end

  test "should show nice" do
    get node_url(@nic)
    assert_response :success
  end
end
