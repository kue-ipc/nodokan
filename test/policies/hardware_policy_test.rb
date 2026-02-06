require "test_helper"
require "helpers/policy_helper"

class HardwarePolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @guest = users(:guest)
    @hardware = hardwares(:desktop)
  end

  test "index" do
    assert_permit(@admin, Hardware, :index)
    assert_permit(@user, Hardware, :index)
    assert_permit(@guest, Hardware, :index)
  end

  test "show" do
    assert_permit(@admin, @hardware, :show)
    assert_permit(@user, @hardware, :show)
    assert_permit(@guest, @hardware, :show)
  end

  test "create" do
    assert_permit(@admin, Hardware.new, :create)
    assert_not_permit(@user, Hardware.new, :create)
    assert_not_permit(@guest, Hardware.new, :create)
  end

  test "update" do
    assert_permit(@admin, @hardware, :update)
    assert_not_permit(@user, @hardware, :update)
    assert_not_permit(@guest, @hardware, :update)
  end

  test "destroy" do
    assert_permit(@admin, @hardware, :destroy)
    assert_not_permit(@user, @hardware, :destroy)
    assert_not_permit(@guest, @hardware, :destroy)
  end

  test "manage" do
    assert_permit(@admin, @hardware, :manage)
    assert_not_permit(@user, @hardware, :manage)
    assert_not_permit(@guest, @hardware, :manage)
  end
end
