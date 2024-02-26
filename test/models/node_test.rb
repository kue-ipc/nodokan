require "test_helper"

class NodeTest < ActiveSupport::TestCase
  setup do
    @node = nodes(:desktop)
  end

  test "flag" do
    @node.specific = false
    @node.logical = false
    assert_nil @node.flag

    @node.specific = true
    @node.logical = false
    assert_equal "s", @node.flag

    @node.specific = false
    @node.logical = true
    assert_equal "l", @node.flag

    @node.specific = true
    @node.logical = true
    assert_includes ["ls", "sl"], @node.flag
  end

  test "flag assign" do
    @node.flag = "ls"
    assert @node.specific
    assert @node.logical

    @node.flag = nil
    assert_not @node.specific
    assert_not @node.logical

    @node.flag = ""
    assert_not @node.specific
    assert_not @node.logical

    @node.flag = "s"
    assert @node.specific
    assert_not @node.logical

    @node.flag = "l"
    assert_not @node.specific
    assert @node.logical

    @node.flag = "sl"
    assert @node.specific
    assert @node.logical
  end
end
