require "test_helper"

class NodeTest < ActiveSupport::TestCase
  setup do
    @node = nodes(:desktop)
  end

  test "flag" do
    @node.specific = false
    @node.public = false
    @node.dns = false
    assert_nil @node.flag

    @node.specific = true
    @node.public = false
    @node.dns = false
    assert_equal "s", @node.flag

    @node.specific = false
    @node.public = true
    @node.dns = false
    assert_equal "p", @node.flag

    @node.specific = false
    @node.public = false
    @node.dns = true
    assert_equal "d", @node.flag

    @node.specific = true
    @node.public = true
    @node.dns = true
    assert_equal "spd".each_char.sort, @node.flag.each_char.sort
  end

  test "flag assign" do
    @node.flag = nil
    assert_not @node.specific
    assert_not @node.public
    assert_not @node.dns

    @node.flag = ""
    assert_not @node.specific
    assert_not @node.public
    assert_not @node.dns

    @node.flag = "s"
    assert @node.specific
    assert_not @node.public
    assert_not @node.dns

    @node.flag = "p"
    assert_not @node.specific
    assert @node.public
    assert_not @node.dns

    @node.flag = "d"
    assert_not @node.specific
    assert_not @node.public
    assert @node.dns

    @node.flag = "spd"
    assert @node.specific
    assert @node.public
    assert @node.dns
  end
end
