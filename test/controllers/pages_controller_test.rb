require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  class SignInAdmin < PagesControllerTest
    setup do
      sign_in users(:admin)
    end

    test 'should get root' do
      get root_url
      assert_response :success
      assert_select 'span', 'admin'
      assert_select 'a', '管理'
    end

    test 'should get about' do
      get about_url
      assert_response :success
    end
  end

  class SignInUser < PagesControllerTest
    setup do
      sign_in users(:user)
    end

    test 'should get root' do
      get root_url
      assert_response :success
      assert_select 'span', 'user'
    end

    test 'should get about' do
      get about_url
      assert_response :success
    end
  end

  class Anonymous < PagesControllerTest
    test 'get root with login' do
      get root_url
      assert_response :success
      assert_select 'form#new_user'
    end

    test 'should get about' do
      get about_url
      assert_response :success
    end
  end
end
