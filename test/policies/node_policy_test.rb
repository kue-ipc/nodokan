require "test_helper"
require "helpers/policy_helper"

class NodePolicyTest < ActiveSupport::TestCase
  include PolicyHelper

  def setup
    @admin = users(:admin)
    @user = users(:user)
    @other = users(:other)
    @guest = users(:guest)
    @less = users(:less)
    @node = nodes(:desktop)
  end

  test "scope" do
    assert_equal Node.count, policy_scope(@admin, Node).count
    # user can see only their nodes
    user_nodes = policy_scope(@user, Node)
    assert_operator 0, :<, user_nodes.count
    assert user_nodes.all? { |node| node.user == @user }
  end

  test "index" do
    assert_permit(@admin, Node, :index)
    assert_permit(@user, Node, :index)
    assert_permit(@guest, Node, :index)
  end

  test "show" do
    assert_permit(@admin, @node, :show)
    assert_permit(@user, @node, :show)
    assert_not_permit(@other, @node, :show)
    assert_not_permit(@guest, @node, :show)
  end

  test "create" do
    user_node = Node.new(user: @user)
    assert_permit(@admin, user_node, :create)
    assert_permit(@user, user_node, :create)
    assert_not_permit(@other, user_node, :create)
    assert_not_permit(@guest, user_node, :create)

    assert_permit(@other, Node.new(user: @other), :create)
    assert_permit(@guest, Node.new(user: @guest), :create)
    assert_not_permit(@less, Node.new(user: @less), :create)
  end

  test "update" do
    assert_permit(@admin, @node, :update)
    assert_permit(@user, @node, :update)
    assert_not_permit(@other, @node, :update)
    assert_not_permit(@guest, @node, :update)
  end

  test "destroy" do
    assert_permit(@admin, @node, :destroy)
    assert_permit(@user, @node, :destroy)
    assert_not_permit(@other, @node, :destroy)
    assert_not_permit(@guest, @node, :destroy)
  end

  test "copy" do
    assert_permit(@admin, @node, :copy)
    assert_permit(@user, @node, :copy)
    assert_not_permit(@other, @node, :copy)
  end

  test "transfer" do
    assert_permit(@admin, @node, :transfer)
    assert_permit(@user, @node, :transfer)
    assert_not_permit(@other, @node, :transfer)
    assert_not_permit(@guest, @node, :transfer)
  end

  test "confirm" do
    # confirm requires Settings.feature.confirmation && update?
    if Settings.feature.confirmation
      assert_permit(@admin, @node, :confirm)
      assert_permit(@user, @node, :confirm)
      assert_not_permit(@other, @node, :confirm)
    end
  end

  test "specific_apply" do
    # specific_apply requires Settings.feature.specific_node && update?
    if Settings.feature.specific_node
      assert_permit(@admin, @node, :specific_apply)
      assert_permit(@user, @node, :specific_apply)
      assert_not_permit(@other, @node, :specific_apply)
    end
  end
end
