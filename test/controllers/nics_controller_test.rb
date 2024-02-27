require "test_helper"

class NicsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @nic = nodes(:desktop)
  end

  # admin

  # user

  test "user should show nice" do
    sign_in users(:admin)
    get node_url(@nic)
    assert_response :success
  end

  # no login
end
