require "test_helper"
require "helpers/policy_helper"

class OperatingSystemPolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @guest = users(:guest)
    @operating_system = operating_systems(:win)
  end

  test "index" do
    assert_permit(@admin, OperatingSystem, :index)
    assert_permit(@user, OperatingSystem, :index)
    assert_permit(@guest, OperatingSystem, :index)
  end

  test "show" do
    assert_permit(@admin, @operating_system, :show)
    assert_permit(@user, @operating_system, :show)
    assert_permit(@guest, @operating_system, :show)
  end

  test "create" do
    assert_permit(@admin, OperatingSystem.new, :create)
    assert_not_permit(@user, OperatingSystem.new, :create)
    assert_not_permit(@guest, OperatingSystem.new, :create)
  end

  test "update" do
    assert_permit(@admin, @operating_system, :update)
    assert_not_permit(@user, @operating_system, :update)
    assert_not_permit(@guest, @operating_system, :update)
  end

  test "destroy" do
    assert_permit(@admin, @operating_system, :destroy)
    assert_not_permit(@user, @operating_system, :destroy)
    assert_not_permit(@guest, @operating_system, :destroy)
  end

  test "manage" do
    assert_permit(@admin, @operating_system, :manage)
    assert_not_permit(@user, @operating_system, :manage)
    assert_not_permit(@guest, @operating_system, :manage)
  end
end
