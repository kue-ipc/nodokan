require "test_helper"
require "helpers/policy_helper"

class BulkPolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @other = users(:other)
    @guest = users(:guest)
    @bulk = bulks(:import_node)
  end

  # Scope tests
  test "scope" do
    assert_equal Bulk.count, policy_scope(@admin, Bulk).count
    assert_equal Bulk.where(user: @user).count, policy_scope(@user, Bulk).count
    assert_equal Bulk.where(user: @other).count, policy_scope(@other, Bulk).count
    assert_equal 0, policy_scope(@guest, Bulk).count
  end

  test "show" do
    assert_permit(@admin, @bulk, :show)
    assert_permit(@user, @bulk, :show)
    assert_not_permit(@other, @bulk, :show)
    assert_not_permit(@guest, @bulk, :show)
  end

  test "create" do
    assert_permit(@admin, Bulk.new, :create)
    assert_permit(@user, Bulk.new, :create)
    assert_not_permit(@guest, Bulk.new, :create)
  end

  test "update" do
    assert_permit(@admin, @bulk, :update)
    assert_permit(@user, @bulk, :update)
    assert_not_permit(@other, @bulk, :update)
    assert_not_permit(@guest, @bulk, :update)
  end

  test "destroy" do
    assert_permit(@admin, @bulk, :destroy)
    assert_permit(@user, @bulk, :destroy)
    assert_not_permit(@other, @bulk, :destroy)
    assert_not_permit(@guest, @bulk, :destroy)
  end

  test "cancel" do
    assert_permit(@admin, @bulk, :cancel)
    assert_permit(@user, @bulk, :cancel)
    assert_not_permit(@other, @bulk, :cancel)
    assert_not_permit(@guest, @bulk, :cancel)
  end
end
