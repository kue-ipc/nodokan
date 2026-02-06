require "test_helper"
require "helpers/policy_helper"

class NetworkPolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @other = users(:other)
    @guest = users(:guest)
    @network = networks(:server)
    @network_other = networks(:client)
  end

  test "scope" do
    assert_equal Network.count, policy_scope(@admin, Network).count
    # user is assigned to some networks
    user_networks = policy_scope(@user, Network)
    assert_operator 0, :<, user_networks.count
    assert user_networks.all? { |network| network.users.include?(@user) }
  end

  test "index" do
    assert_permit(@admin, Network, :index)
    assert_permit(@user, Network, :index)
    assert_permit(@guest, Network, :index)
  end

  test "show" do
    assert_permit(@admin, @network, :show)
    assert_permit(@user, @network, :show)
    assert_not_permit(@other, @network, :show)
    assert_not_permit(@guest, @network, :show)

    assert_permit(@admin, @network_other, :show)
    assert_permit(@user, @network_other, :show)
    assert_permit(@other, @network_other, :show)
    assert_permit(@guest, @network_other, :show)
  end

  test "create" do
    assert_permit(@admin, Network.new, :create)
    assert_not_permit(@user, Network.new, :create)
    assert_not_permit(@guest, Network.new, :create)
  end

  test "update" do
    assert_permit(@admin, @network, :update)
    assert_not_permit(@user, @network, :update)
    assert_not_permit(@guest, @network, :update)
  end

  test "destroy" do
    assert_permit(@admin, @network, :destroy)
    assert_not_permit(@user, @network, :destroy)
    assert_not_permit(@guest, @network, :destroy)
  end
end
