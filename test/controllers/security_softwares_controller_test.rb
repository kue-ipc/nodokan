require 'test_helper'

class SecuritySoftwaresControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get security_softwares_index_url
    assert_response :success
  end
end
