require "test_helper"
require "helpers/policy_helper"

class SecuritySoftwarePolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @guest = users(:guest)
    @security_software = security_softwares(:defender)
  end

  test "index" do
    assert_permit(@admin, SecuritySoftware, :index)
    assert_permit(@user, SecuritySoftware, :index)
    assert_permit(@guest, SecuritySoftware, :index)
  end

  test "show" do
    assert_permit(@admin, @security_software, :show)
    assert_permit(@user, @security_software, :show)
    assert_permit(@guest, @security_software, :show)
  end

  test "create" do
    assert_permit(@admin, SecuritySoftware.new, :create)
    assert_not_permit(@user, SecuritySoftware.new, :create)
    assert_not_permit(@guest, SecuritySoftware.new, :create)
  end

  test "update" do
    assert_permit(@admin, @security_software, :update)
    assert_not_permit(@user, @security_software, :update)
    assert_not_permit(@guest, @security_software, :update)
  end

  test "destroy" do
    assert_permit(@admin, @security_software, :destroy)
    assert_not_permit(@user, @security_software, :destroy)
    assert_not_permit(@guest, @security_software, :destroy)
  end

  test "manage" do
    assert_permit(@admin, @security_software, :manage)
    assert_not_permit(@user, @security_software, :manage)
    assert_not_permit(@guest, @security_software, :manage)
  end
end
