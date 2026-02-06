require "test_helper"
require "helpers/policy_helper"

class NicPolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @other = users(:other)
    @guest = users(:guest)
    @nic = nics(:desktop)
  end

  test "scope" do
    assert_equal Nic.count, policy_scope(@admin, Nic).count
    # user can see only their nics
    user_nics = policy_scope(@user, Nic)
    assert_operator 0, :<, user_nics.count
    assert user_nics.all? { |nic| nic.node&.user == @user }
  end

  test "index" do
    assert_permit(@admin, Nic, :index)
    assert_permit(@user, Nic, :index)
    assert_permit(@guest, Nic, :index)
  end

  test "show" do
    assert_permit(@admin, @nic, :show)
    assert_permit(@user, @nic, :show)
    assert_not_permit(@other, @nic, :show)
    assert_not_permit(@guest, @nic, :show)
  end

  test "create" do
    user_nic = Nic.new(node: nodes(:desktop))
    assert_permit(@admin, user_nic, :create)
    assert_permit(@user, user_nic, :create)
    assert_not_permit(@other, user_nic, :create)
    assert_not_permit(@guest, user_nic, :create)
  end

  test "update" do
    assert_permit(@admin, @nic, :update)
    assert_permit(@user, @nic, :update)
    assert_not_permit(@other, @nic, :update)
    assert_not_permit(@guest, @nic, :update)
  end

  test "destroy" do
    assert_permit(@admin, @nic, :destroy)
    assert_permit(@user, @nic, :destroy)
    assert_not_permit(@other, @nic, :destroy)
    assert_not_permit(@guest, @nic, :destroy)
  end
end
