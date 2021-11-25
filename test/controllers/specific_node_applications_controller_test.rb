require "test_helper"

class SpecificNodeApplicationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
  end

  # test "should get new" do
  #   get specific_node_applications_new_url
  #   assert_response :success
  # end

  # test "should get create" do
  #   get specific_node_applications_create_url
  #   assert_response :success
  # end
end
