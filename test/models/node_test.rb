require "test_helper"

class NodeTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @node = nodes(:note)
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

  test "enable node" do
    # enablde -> enabled
    assert @node.enabled?
    assert_no_enqueued_jobs do
      assert @node.enable!
    end
    assert @node.enabled?

    # disabled -> enabled
    @node = nodes(:disabled)
    assert_not @node.enabled?
    assert_enqueued_with(job: RadiusMacAddJob) do
      assert_enqueued_with(job: KeaReservation4AddJob) do
        assert_enqueued_with(job: KeaReservation6AddJob) do
          assert @node.enable!
        end
      end
    end
    assert @node.enabled?
  end

  test "disbale node" do
    # enabled -> disabled
    assert @node.enabled?
    assert_enqueued_with(job: RadiusMacDelJob) do
      assert_enqueued_with(job: KeaReservation4DelJob) do
        assert_enqueued_with(job: KeaReservation6DelJob) do
          assert @node.disable!
        end
      end
    end
    assert @node.disabled?

    # disabled -> disabled
    @node = nodes(:disabled)
    assert_not @node.enabled?
    assert_no_enqueued_jobs do
      assert @node.enable!
    end
    assert @node.enabled?
  end
end
