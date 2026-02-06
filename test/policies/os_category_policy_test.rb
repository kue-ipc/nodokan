require "test_helper"
require "helpers/policy_helper"

class OsCategoryPolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @guest = users(:guest)
    @os_category = os_categories(:win)
  end

  test "index" do
    assert_permit(@admin, OsCategory, :index)
    assert_permit(@user, OsCategory, :index)
    assert_permit(@guest, OsCategory, :index)
  end

  test "show" do
    assert_permit(@admin, @os_category, :show)
    assert_permit(@user, @os_category, :show)
    assert_permit(@guest, @os_category, :show)
  end

  test "create" do
    assert_permit(@admin, OsCategory.new, :create)
    assert_not_permit(@user, OsCategory.new, :create)
    assert_not_permit(@guest, OsCategory.new, :create)
  end

  test "update" do
    assert_permit(@admin, @os_category, :update)
    assert_not_permit(@user, @os_category, :update)
    assert_not_permit(@guest, @os_category, :update)
  end

  test "destroy" do
    assert_permit(@admin, @os_category, :destroy)
    assert_not_permit(@user, @os_category, :destroy)
    assert_not_permit(@guest, @os_category, :destroy)
  end

  test "manage" do
    assert_permit(@admin, @os_category, :manage)
    assert_not_permit(@user, @os_category, :manage)
    assert_not_permit(@guest, @os_category, :manage)
  end
end
