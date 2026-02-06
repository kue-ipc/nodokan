require "test_helper"
require "helpers/policy_helper"

class PlacePolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @guest = users(:guest)
    @place = places(:office_room)
  end

  test "index" do
    assert_permit(@admin, Place, :index)
    assert_permit(@user, Place, :index)
    assert_permit(@guest, Place, :index)
  end

  test "show" do
    assert_permit(@admin, @place, :show)
    assert_permit(@user, @place, :show)
    assert_permit(@guest, @place, :show)
  end

  test "create" do
    assert_permit(@admin, Place.new, :create)
    assert_not_permit(@user, Place.new, :create)
    assert_not_permit(@guest, Place.new, :create)
  end

  test "update" do
    assert_permit(@admin, @place, :update)
    assert_not_permit(@user, @place, :update)
    assert_not_permit(@guest, @place, :update)
  end

  test "destroy" do
    assert_permit(@admin, @place, :destroy)
    assert_not_permit(@user, @place, :destroy)
    assert_not_permit(@guest, @place, :destroy)
  end

  test "manage" do
    assert_permit(@admin, @place, :manage)
    assert_not_permit(@user, @place, :manage)
    assert_not_permit(@guest, @place, :manage)
  end
end
