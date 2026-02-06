require "test_helper"
require "helpers/policy_helper"

class UserPolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @other = users(:other)
    @guest = users(:guest)
  end

  test "scope" do
    assert_equal User.count, policy_scope(@admin, User).count
    assert_equal 1, policy_scope(@user, User).count
    assert_equal 1, policy_scope(@other, User).count
    assert_equal 1, policy_scope(@guest, User).count
  end

  test "index" do
    assert_permit(@admin, User, :index)
    assert_not_permit(@user, User, :index)
    assert_not_permit(@guest, User, :index)
  end

  test "show" do
    assert_permit(@admin, @user, :show)
    assert_permit(@user, @user, :show)
    assert_not_permit(@other, @user, :show)
    assert_not_permit(@guest, @user, :show)
  end

  test "create" do
    assert_permit(@admin, User.new, :create)
    assert_not_permit(@user, User.new, :create)
    assert_not_permit(@guest, User.new, :create)
  end

  test "update" do
    assert_permit(@admin, @user, :update)
    assert_not_permit(@user, @user, :update)
    assert_not_permit(@guest, @user, :update)
  end

  test "destroy" do
    assert_permit(@admin, @user, :destroy)
    assert_not_permit(@user, @user, :destroy)
    assert_not_permit(@guest, @user, :destroy)
  end
end
