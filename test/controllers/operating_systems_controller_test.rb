require 'test_helper'

class OperatingSystemsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get operating_systems_url
    assert_response :success
  end
end
