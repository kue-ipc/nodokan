require "test_helper"

class NodeTest < ActiveSupport::TestCase
  setup do
    @node = nodes(:desktop)
  end

  test "flag" do
    @node.specific = false
    @node.virtual = false
    assert_nil @node.flag

    @node.specific = true
    @node.virtual = false
    assert_equal "s", @node.flag

    @node.specific = false
    @node.virtual = true
    assert_equal "v", @node.flag

    @node.specific = true
    @node.virtual = true
    assert_equal "sv", @node.flag
  end

  test "flag assign" do
    @node.flag = "vs"
    assert @node.specific
    assert @node.virtual

    @node.flag = nil
    assert_not @node.specific
    assert_not @node.virtual

    @node.flag = ""
    assert_not @node.specific
    assert_not @node.virtual

    @node.flag = "s"
    assert @node.specific
    assert_not @node.virtual

    @node.flag = "v"
    assert_not @node.specific
    assert @node.virtual

    @node.flag = "sv"
    assert @node.specific
    assert @node.virtual
  end
end
