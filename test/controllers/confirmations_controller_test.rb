require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @confirmation = confirmations(:one)
  end

  class SignInAdmin < ConfirmationsControllerTest
    setup do
      sign_in users(:admin)
    end

    test 'should create confirmation' do
      assert_difference('Confirmation.count') do
        post confirmations_url,
          params: {
            confirmation: {
              existence: @confirmation.existence,
              content: @confirmation.content,
              os_update: @confirmation.os_update,
              app_update: @confirmation.app_update,
              node_id: @confirmation.node_id,
              registered_content: @confirmation.registered_content,
              security_software_name: @confirmation.security_software_name,
              securiy_software: @confirmation.securiy_software,
              securiyt_software_update: @confirmation.securiyt_software_update,
              soft_update: @confirmation.soft_update,
              store_update: @confirmation.store_update,
              updated_date: @confirmation.updated_date,
              user_id: @confirmation.user_id,
            },
          }
      end

      assert_redirected_to confirmation_url(Confirmation.last)
    end

    test 'should update confirmation' do
      patch confirmation_url(@confirmation), params: {confirmation: {existence: @confirmation.existence, app_update: @confirmation.app_update, node_id: @confirmation.node_id, os_update: @confirmation.os_update, registered_content: @confirmation.registered_content, security_software_name: @confirmation.security_software_name, securiy_software: @confirmation.securiy_software, securiyt_software_update: @confirmation.securiyt_software_update, soft_update: @confirmation.soft_update, store_update: @confirmation.store_update, updated_date: @confirmation.updated_date, user_id: @confirmation.user_id}}
      assert_redirected_to confirmation_url(@confirmation)
    end
  end

  class SignInUser < ConfirmationsControllerTest
    setup do
      sign_in users(:user01)
    end
  end

  class Anonymous < ConfirmationsControllerTest
    test 'redirect to login INSTEAD OF get index' do
      get mail_groups_url
      assert_redirected_to new_user_session_path
    end

    test 'redirect to login INSTEAD OF show mail_group' do
      get mail_group_url(@mail_group)
      assert_redirected_to new_user_session_path
    end
  end
end
