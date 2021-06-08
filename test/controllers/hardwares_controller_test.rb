require 'test_helper'

class HardwaresControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  class SignInAdmin < HardwaresControllerTest
    setup do
      sign_in users(:admin)
    end

    test 'should get edit' do
      get hardwares_edit_url
      assert_response :success
    end

    test 'should get update' do
      get hardwares_update_url
      assert_response :success
    end
  end

  class SignInUser < HardwaresControllerTest
    setup do
      sign_in users(:user)
    end

    test 'should get index' do
      get hardwares_index_url
      assert_response :success
    end
  end

  class Anonymous < HardwaresControllerTest
    test 'redirect to login INSTEAD OF get index' do
      get hardwares_index_url
      assert_redirected_to new_user_session_path
    end
  end
end
