require "test_helper"
require "helpers/policy_helper"

class DeviceTypePolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @guest = users(:guest)
    @device_type = device_types(:pc)
  end

  test "index" do
    assert_permit(@admin, DeviceType, :index)
    assert_permit(@user, DeviceType, :index)
    assert_permit(@guest, DeviceType, :index)
  end

  test "show" do
    assert_permit(@admin, @device_type, :show)
    assert_permit(@user, @device_type, :show)
    assert_permit(@guest, @device_type, :show)
  end

  test "create" do
    assert_permit(@admin, DeviceType.new, :create)
    assert_not_permit(@user, DeviceType.new, :create)
    assert_not_permit(@guest, DeviceType.new, :create)
  end

  test "update" do
    assert_permit(@admin, @device_type, :update)
    assert_not_permit(@user, @device_type, :update)
    assert_not_permit(@guest, @device_type, :update)
  end

  test "destroy" do
    assert_permit(@admin, @device_type, :destroy)
    assert_not_permit(@user, @device_type, :destroy)
    assert_not_permit(@guest, @device_type, :destroy)
  end

  test "manage" do
    assert_permit(@admin, @device_type, :manage)
    assert_not_permit(@user, @device_type, :manage)
    assert_not_permit(@guest, @device_type, :manage)
  end
end
