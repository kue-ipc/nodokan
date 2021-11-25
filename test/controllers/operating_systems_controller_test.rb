require 'test_helper'

class OperatingSystemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
  end

  test 'should get index' do
    get operating_systems_url
    assert_response :success
  end
end
