require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @confirmation = confirmations(:desktop)
  end

  class SignInAdmin < ConfirmationsControllerTest
    setup do
      sign_in users(:admin)
    end

    test 'should create confirmation' do
      other_node = nodes(:other_desktop)
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
                os_category_id: @confirmation.security_software.os_category_id,
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
      sign_in users(:user)
    end

    test 'should create confirmation' do
      other_node = nodes(:other_desktop)
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

    test 'should NOT create confirmation for other owner' do
      other_node = nodes(:admin_desktop)
      assert_no_difference('Confirmation.count') do
        assert_raises(Pundit::NotAuthorizedError) do
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
      end
    end
  end

  class Anonymous < ConfirmationsControllerTest
    test 'redirect to login INSTEAD OF create confirmation' do
      other_node = nodes(:other_desktop)
      assert_no_difference('Confirmation.count') do
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
      assert_redirected_to new_user_session_path
    end

    test 'redirect to login INSTEAD OF update confirmation' do
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
      assert_redirected_to new_user_session_path

    end
  end
end
