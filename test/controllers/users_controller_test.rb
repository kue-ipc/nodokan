require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def get_message(key)
    model_name = User.model_name.human
    case key
    when :create_success
      I18n.t("messages.success_action", model: model_name,
        action: I18n.t("actions.create"))
    when :create_failure
      I18n.t("messages.failure_action", model: model_name,
        action: I18n.t("actions.create"))
    when :update_success
      I18n.t("messages.success_action", model: model_name,
        action: I18n.t("actions.update"))
    when :update_failure
      I18n.t("messages.failure_action", model: model_name,
        action: I18n.t("actions.update"))
    when :destroy_success
      I18n.t("messages.success_action", model: model_name,
        action: I18n.t("actions.delete"))
    when :destroy_failure
      I18n.t("messages.failure_action", model: model_name,
        action: I18n.t("actions.delete"))
    when :unauthenticated
      I18n.t("devise.failure.unauthenticated")
    end
  end

  setup do
    @user = users(:user)
  end

  # index

  test "should NOT get index" do
    sign_in users(:user)
    get users_url
    assert_response :forbidden
  end

  test "admin should get index" do
    sign_in users(:admin)
    get users_url
    assert_response :success
  end

  test "guest redirect to login INSTEAD OF get index" do
    get users_url
    assert_redirected_to new_user_session_path
  end

  # show

  test "should get show own" do
    sign_in users(:user)
    get user_url(@user)
    assert_response :success
  end

  test "admin should show" do
    sign_in users(:admin)
    get user_url(@user)
    assert_response :success
  end

  test "other should NOT show" do
    sign_in users(:other)
    get user_url(@user)
    assert_response :forbidden
  end

  test "guest redirect to login INSTEAD OF show" do
    get user_url(@user)
    assert_redirected_to new_user_session_path
    assert_equal get_message(:unauthenticated), flash[:alert]
  end

  # update

  test "should NOT get update" do
    sign_in users(:user)
    patch user_url(@user), params: {user: {role: "user"}}
    assert_response :forbidden
  end

  test "admin should update" do
    sign_in users(:admin)
    patch user_url(@user), params: {user: {role: "user"}}
    assert_redirected_to user_url(@user)
    assert_equal get_message(:update_success), flash[:notice]
    user = User.find(@user.id)
    assert_equal "user", user.role
    assert_equal networks(:client), user.auth_network
    assert_nil user.limit
  end

  test "other should NOT update" do
    sign_in users(:other)
    patch user_url(@user), params: {user: {role: "user"}}
    assert_response :forbidden
  end

  test "guest redirect to login INSTEAD OF update" do
    patch user_url(@user), params: {user: {role: "user"}}
    assert_redirected_to new_user_session_path
    assert_equal get_message(:unauthenticated), flash[:alert]
  end

  test "admin should NOT update invalid role" do
    sign_in users(:admin)
    patch user_url(@user), params: {user: {role: "super"}}
    assert_response :success
    assert_equal get_message(:update_failure), flash[:alert]
    user = User.find(@user.id)
    assert_equal "user", user.role
    assert_equal networks(:client), user.auth_network
    assert_nil user.limit
  end

  test "admin should update auth_network_id" do
    sign_in users(:admin)
    patch user_url(@user),
      params: {user: {auth_network_id: networks(:client).id}}
    assert_redirected_to user_url(@user)
    assert_equal get_message(:update_success), flash[:notice]
    user = User.find(@user.id)
    assert_equal "user", user.role
    assert_equal networks(:client), user.auth_network
    assert_nil user.limit
  end

  test "admin should update unlmitied" do
    sign_in users(:admin)
    patch user_url(@user),
      params: {user: {unlimited: true, limit: 0}}
    assert_redirected_to user_url(@user)
    assert_equal get_message(:update_success), flash[:notice]
    user = User.find(@user.id)
    assert_equal "user", user.role
    assert_equal networks(:client), user.auth_network
    assert_nil user.limit
  end

  test "admin should update limit" do
    sign_in users(:admin)
    patch user_url(@user),
      params: {user: {unlimited: false, limit: 1}}
    assert_redirected_to user_url(@user)
    assert_equal get_message(:update_success), flash[:notice]
    user = User.find(@user.id)
    assert_equal "user", user.role
    assert_equal networks(:client), user.auth_network
    assert_equal 1, user.limit
  end

  test "admin should NOT update negative limit" do
    sign_in users(:admin)
    patch user_url(@user),
      params: {user: {unlimited: false, limit: -1}}
    assert_response :success
    assert_equal get_message(:update_failure), flash[:alert]
    user = User.find(@user.id)
    assert_equal "user", user.role
    assert_equal networks(:client), user.auth_network
    assert_nil user.limit
  end

  test "admin should NOT update floating limit" do
    sign_in users(:admin)
    patch user_url(@user),
      params: {user: {unlimited: false, limit: 3.14}}
    assert_response :success
    assert_equal get_message(:update_failure), flash[:alert]
    user = User.find(@user.id)
    assert_equal "user", user.role
    assert_equal networks(:client), user.auth_network
    assert_nil user.limit
  end

  test "admin should update all change" do
    sign_in users(:admin)
    patch user_url(@user),
      params: {user: {
        role: "admin",
        auth_network_id: networks(:free).id,
        unlimited: false,
        limit: 1,
      }}
    assert_redirected_to user_url(@user)
    assert_equal get_message(:update_success), flash[:notice]
    user = User.find(@user.id)
    assert_equal "admin", user.role
    assert_equal networks(:free), user.auth_network
    assert_equal 1, user.limit
  end

  test "admin should update unlmitied for other" do
    sign_in users(:admin)
    @user = users(:other)
    patch user_url(@user),
      params: {user: {unlimited: true, limit: 0}}
    assert_redirected_to user_url(@user)
    assert_equal get_message(:update_success), flash[:notice]
    user = User.find(@user.id)
    assert_equal "user", user.role
    assert_equal networks(:client), user.auth_network
    assert_nil user.limit
  end

  test "admin should update limit for other" do
    sign_in users(:admin)
    @user = users(:other)
    patch user_url(@user),
      params: {user: {unlimited: false, limit: 1}}
    assert_redirected_to user_url(@user)
    assert_equal get_message(:update_success), flash[:notice]
    user = User.find(@user.id)
    assert_equal "user", user.role
    assert_equal networks(:client), user.auth_network
    assert_equal 1, user.limit
  end

  # TODO: 認証ネットワーク以外の場合は弾くべき？
  # test "admin should NOT update auth_network_id for no auth" do
  #   sign_in users(:admin)
  #   patch user_url(@user),
  #     params: {user: {auth_network_id: networks(:server).id}}
  #   assert_response :success
  #   assert_equal get_message(:update_failure), flash[:alert]
  # end

  # sync

  # show current user

  test "should get show current user" do
    sign_in users(:admin)
    get "/user"
    assert_response :success
  end

  test "admin should get show current user" do
    sign_in users(:admin)
    get "/user"
    assert_response :success
  end

  test "guest redirect to login INSTEAD OF show current user" do
    get "/user"
    assert_redirected_to new_user_session_path
    assert_equal get_message(:unauthenticated), flash[:alert]
  end
end
