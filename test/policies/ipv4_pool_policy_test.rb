require "test_helper"
require "helpers/policy_helper"

class Ipv4PoolPolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @guest = users(:guest)
    @ipv4_pool = ipv4_pools(:client1)
  end

  test "scope" do
    assert_equal Ipv4Pool.count, policy_scope(@admin, Ipv4Pool).count
    # userはclientネットワークに所属しているため、clientのpoolが見える
    user_pools = policy_scope(@user, Ipv4Pool)
    assert_operator 0, :<, user_pools.count
    assert user_pools.all? { |pool| @user.networks.include?(pool.network) }
  end

  test "index" do
    assert_permit(@admin, Ipv4Pool, :index)
    assert_permit(@user, Ipv4Pool, :index)
    assert_permit(@guest, Ipv4Pool, :index)
  end

  test "show" do
    assert_permit(@admin, @ipv4_pool, :show)
    assert_permit(@user, @ipv4_pool, :show)
    assert_permit(@guest, @ipv4_pool, :show)
  end

  test "create" do
    assert_permit(@admin, Ipv4Pool.new, :create)
    assert_not_permit(@user, Ipv4Pool.new, :create)
    assert_not_permit(@guest, Ipv4Pool.new, :create)
  end

  test "update" do
    assert_permit(@admin, @ipv4_pool, :update)
    assert_not_permit(@user, @ipv4_pool, :update)
    assert_not_permit(@guest, @ipv4_pool, :update)
  end

  test "destroy" do
    assert_permit(@admin, @ipv4_pool, :destroy)
    assert_not_permit(@user, @ipv4_pool, :destroy)
    assert_not_permit(@guest, @ipv4_pool, :destroy)
  end
end
