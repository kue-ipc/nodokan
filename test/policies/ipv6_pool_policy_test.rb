require "test_helper"
require "helpers/policy_helper"

class Ipv6PoolPolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @guest = users(:guest)
    @ipv6_pool = ipv6_pools(:client1)
  end

  test "scope" do
    assert_equal Ipv6Pool.count, policy_scope(@admin, Ipv6Pool).count
    # userはclientネットワークに所属しているため、clientのpoolが見える
    user_pools = policy_scope(@user, Ipv6Pool)
    assert_operator 0, :<, user_pools.count
    assert user_pools.all? { |pool| @user.networks.include?(pool.network) }
  end

  test "index" do
    assert_permit(@admin, Ipv6Pool, :index)
    assert_permit(@user, Ipv6Pool, :index)
    assert_permit(@guest, Ipv6Pool, :index)
  end

  test "show" do
    assert_permit(@admin, @ipv6_pool, :show)
    assert_permit(@user, @ipv6_pool, :show)
    assert_permit(@guest, @ipv6_pool, :show)
  end

  test "create" do
    assert_permit(@admin, Ipv6Pool.new, :create)
    assert_not_permit(@user, Ipv6Pool.new, :create)
    assert_not_permit(@guest, Ipv6Pool.new, :create)
  end

  test "update" do
    assert_permit(@admin, @ipv6_pool, :update)
    assert_not_permit(@user, @ipv6_pool, :update)
    assert_not_permit(@guest, @ipv6_pool, :update)
  end

  test "destroy" do
    assert_permit(@admin, @ipv6_pool, :destroy)
    assert_not_permit(@user, @ipv6_pool, :destroy)
    assert_not_permit(@guest, @ipv6_pool, :destroy)
  end
end
