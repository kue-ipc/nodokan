require "test_helper"

class SpecificNodeApplicationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get specific_node_applications_new_url
    assert_response :success
  end

  test "should get create" do
    get specific_node_applications_create_url
    assert_response :success
  end
end
