require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @confirmation = confirmations(:two)
  end

  class SignInAdmin < ConfirmationsControllerTest
    setup do
      sign_in users(:admin)
    end

    test 'should create confirmation' do
      other_node = nodes(:three)
      assert_difference('Confirmation.count') do
        post node_confirmation_url(other_node),
          params: {
            confirmation: {
              existence: @confirmation.existence,
              content: @confirmation.content,
              os_update: @confirmation.os_update,
              app_update: @confirmation.app_update,
              security_update: @confirmation.security_update,
              security_scan: @confirmation.security_scan,
              security_software: {
                os_category: @confirmation.security_software.os_category,
                installation_method:
                  @confirmation.security_software.installation_method,
                name: @confirmation.security_software.name,
              },
            },
          }
      end
      assert_redirected_to node_url(other_node)
    end

    test 'should update confirmation' do
      patch node_confirmation_url(@confirmation.node),
        params: {
          confirmation: {
            existence: @confirmation.existence,
            content: @confirmation.content,
            os_update: @confirmation.os_update,
            app_update: @confirmation.app_update,
            security_update: @confirmation.security_update,
            security_scan: @confirmation.security_scan,
            security_software: {
              os_category: @confirmation.security_software.os_category,
              installation_method:
                @confirmation.security_software.installation_method,
              name: @confirmation.security_software.name,
            },
          },
        }
      assert_redirected_to node_url(@confirmation.node)
    end
  end

  class SignInUser < ConfirmationsControllerTest
    setup do
      sign_in users(:user01)
    end

    test 'should create confirmation' do
      other_node = nodes(:three)
      assert_difference('Confirmation.count') do
        post node_confirmation_url(other_node),
          params: {
            confirmation: {
              existence: @confirmation.existence,
              content: @confirmation.content,
              os_update: @confirmation.os_update,
              app_update: @confirmation.app_update,
              security_update: @confirmation.security_update,
              security_scan: @confirmation.security_scan,
              security_software: {
                os_category: @confirmation.security_software.os_category,
                installation_method:
                  @confirmation.security_software.installation_method,
                name: @confirmation.security_software.name,
              },
            },
          }
      end
      assert_redirected_to node_url(other_node)
    end

    test 'should update confirmation' do
      patch node_confirmation_url(@confirmation.node),
        params: {
          confirmation: {
            existence: @confirmation.existence,
            content: @confirmation.content,
            os_update: @confirmation.os_update,
            app_update: @confirmation.app_update,
            security_update: @confirmation.security_update,
            security_scan: @confirmation.security_scan,
            security_software: {
              os_category: @confirmation.security_software.os_category,
              installation_method:
                @confirmation.security_software.installation_method,
              name: @confirmation.security_software.name,
            },
          },
        }
      assert_redirected_to node_url(@confirmation.node)
    end
  end

  # class Anonymous < ConfirmationsControllerTest
  #   test 'redirect to login INSTEAD OF get index' do
  #     get mail_groups_url
  #     assert_redirected_to new_user_session_path
  #   end

  #   test 'redirect to login INSTEAD OF show mail_group' do
  #     get mail_group_url(@mail_group)
  #     assert_redirected_to new_user_session_path
  #   end
  # end
end
