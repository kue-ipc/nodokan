require "test_helper"

class NodeTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @node = nodes(:node)
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
    @node = Node.find(@node.id)
    assert @node.enabled?

    # disabled -> enabled
    @node = nodes(:disabled)
    assert @node.disabled?
    assert_enqueued_with(job: RadiusMacAddJob) do
      assert_enqueued_with(job: KeaReservation4AddJob) do
        assert_enqueued_with(job: KeaReservation6AddJob) do
          assert @node.enable!
        end
      end
    end
    @node = Node.find(@node.id)
    assert @node.enabled?
  end

  test "disable node" do
    # TODO: 予約が存在するfixtureを用意すべき
    @node = nodes(:note)
    # enabled -> disabled
    assert @node.enabled?
    assert_enqueued_with(job: RadiusMacDelJob) do
      assert_enqueued_with(job: KeaReservation4DelJob) do
        assert_enqueued_with(job: KeaReservation6DelJob) do
          assert @node.disable!
        end
      end
    end
    @node = Node.find(@node.id)
    assert @node.disabled?

    # disabled -> disabled
    @node = nodes(:disabled)
    assert @node.disabled?
    assert_no_enqueued_jobs do
      assert @node.disable!
    end
    @node = Node.find(@node.id)
    assert @node.disabled?
  end

  test "should destroy node" do
    # last connection and expired -> destroy
    @node.nics.update!(auth_at: (1.year + 2.months).ago)
    @node.confirmation.update!(confirmed_at: (2.years + 2.months).ago)
    @node.reload
    assert_operator @node.connected_at, :<, 1.year.ago
    assert_operator @node.confirmation.expiration, :<, 1.year.ago
    assert_equal :expired, @node.confirmation_status
    assert @node.should_destroy?

    # not connected and expired -> destroy
    @node.update_attribute!(:created_at, 2.months.ago)
    @node.nics.update!(auth_at: nil)
    @node.reload
    assert_operator @node.created_at, :<, 1.month.ago
    assert_nil @node.connected_at
    assert_operator @node.confirmation.expiration, :<, 1.year.ago
    assert_equal :expired, @node.confirmation_status
    assert @node.should_destroy?

    # not connected and uncofirmed -> destroy
    @node.confirmation.destroy!
    @node.reload
    assert_operator @node.created_at, :<, 1.month.ago
    assert_nil @node.connected_at
    assert_equal :unconfirmed, @node.confirmation_status
    assert @node.should_destroy?

    # last connection and uncofirmed -> destroy
    @node.nics.update!(auth_at: (1.year + 2.months).ago)
    @node.reload
    assert_operator @node.connected_at, :<, 1.year.ago
    assert_equal :unconfirmed, @node.confirmation_status
    assert @node.should_destroy?
  end

  test "should not destroy node" do
    assert_equal :approved, @node.confirmation_status
    assert_operator @node.confirmation.expiration, :>, 1.year.ago
    assert_operator @node.connected_at, :>, 1.year.ago
    assert_not @node.should_destroy?
  end

  test "should not destroy permanent node" do
    @node.nics.update!(auth_at: (1.year + 2.months).ago)
    @node.confirmation.update!(confirmed_at: (2.years + 2.months).ago)
    @node.reload
    assert_operator @node.connected_at, :<, 1.year.ago
    assert_operator @node.confirmation.expiration, :<, 1.year.ago
    assert_equal :expired, @node.confirmation_status
    assert @node.should_destroy?

    @node.update!(permanent: true)
    @node.reload
    assert_not @node.should_destroy?
  end

  test "should not destroy node it unverifiable network" do
    @node.update_attribute!(:created_at, 2.months.ago)
    @node.nics.update!(auth_at: nil)
    @node.confirmation.destroy
    @node.reload
    assert_operator @node.created_at, :<, 1.month.ago
    assert_nil @node.connected_at
    assert_equal :unconfirmed, @node.confirmation_status
    assert @node.should_destroy?

    Network.all.update!(unverifiable: true)
    @node.reload
    assert @node.nics.first.network.unverifiable?
    assert_not @node.should_destroy?
  end

  test "should disable node" do
    # expired -> disable
    @node.confirmation.update!(confirmed_at: (2.years + 2.months).ago)
    @node.reload
    assert_operator @node.confirmation.expiration, :<, 1.year.ago
    assert_equal :expired, @node.confirmation_status
    assert @node.should_disable?

    # uncofirmed -> disable
    @node.update_attribute!(:created_at, (1.year + 1.month).ago)
    @node.confirmation.destroy!
    @node.reload
    assert_operator @node.created_at, :<, 1.year.ago
    assert_equal :unconfirmed, @node.confirmation_status
    assert @node.should_disable?
  end

  test "should not disable node" do
    assert_equal :approved, @node.confirmation_status
    assert_not @node.should_disable?
  end

  test "should not disable permanent node" do
    @node.confirmation.update!(confirmed_at: (2.years + 2.months).ago)
    @node.reload
    assert_operator @node.confirmation.expiration, :<, 1.year.ago
    assert_equal :expired, @node.confirmation_status
    assert @node.should_disable?

    @node.update!(permanent: true)
    assert @node.permanent?
    assert_not @node.should_disable?
  end
end
