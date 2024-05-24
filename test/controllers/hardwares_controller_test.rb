require "test_helper"

class HardwaresControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @hardware = hardwares(:desktop)
  end

  # admin

  test "admin should get index" do
    sign_in users(:admin)
    get hardwares_url
    assert_response :success
  end

  # test 'should get edit' do
  #   get hardwares_edit_url
  #   assert_response :success
  # end

  # test 'should get update' do
  #   get hardwares_update_url
  #   assert_response :success
  # end

  # user

  test "user should get index" do
    sign_in users(:user)
    get hardwares_url
    assert_response :success
  end

  # no login

  test "redirect to login INSTEAD OF get index" do
    get hardwares_url
    assert_response :unauthorized
  end
end
