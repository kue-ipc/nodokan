require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @confirmation = confirmations(:one)
  end

  test "should get index" do
    get confirmations_url
    assert_response :success
  end

  test "should get new" do
    get new_confirmation_url
    assert_response :success
  end

  test "should create confirmation" do
    assert_difference('Confirmation.count') do
      post confirmations_url,
        params: {
          confirmation: {
            existence: @confirmation.existence,
            ms_upadte: @confirmation.ms_upadte,
            node_id: @confirmation.node_id,
            os_update: @confirmation.os_update,
            registered_content: @confirmation.registered_content,
            security_software_name: @confirmation.security_software_name,
            securiy_software: @confirmation.securiy_software,
            securiyt_software_update: @confirmation.securiyt_software_update,
            soft_update: @confirmation.soft_update,
            store_update: @confirmation.store_update,
            updated_date: @confirmation.updated_date,
            user_id: @confirmation.user_id
          }
        }
    end

    assert_redirected_to confirmation_url(Confirmation.last)
  end

  test "should show confirmation" do
    get confirmation_url(@confirmation)
    assert_response :success
  end

  test "should get edit" do
    get edit_confirmation_url(@confirmation)
    assert_response :success
  end

  test "should update confirmation" do
    patch confirmation_url(@confirmation), params: { confirmation: { existence: @confirmation.existence, ms_upadte: @confirmation.ms_upadte, node_id: @confirmation.node_id, os_update: @confirmation.os_update, registered_content: @confirmation.registered_content, security_software_name: @confirmation.security_software_name, securiy_software: @confirmation.securiy_software, securiyt_software_update: @confirmation.securiyt_software_update, soft_update: @confirmation.soft_update, store_update: @confirmation.store_update, updated_date: @confirmation.updated_date, user_id: @confirmation.user_id } }
    assert_redirected_to confirmation_url(@confirmation)
  end

  test "should destroy confirmation" do
    assert_difference('Confirmation.count', -1) do
      delete confirmation_url(@confirmation)
    end

    assert_redirected_to confirmations_url
  end
end
