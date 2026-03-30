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

  # rubocop: disable Rails/SkipsModelValidations

  test "should destroy node" do
    @node.update_attribute(:created_at, 3.years.ago)

    # last connection and expired -> destroy
    @node.nics.each { |nic| nic.update_attribute(:auth_at, 2.years.ago) }
    @node.confirmation.update_attribute(:confirmed_at, 2.years.ago)
    @node = Node.find(@node.id)
    assert_operator 1.year.ago, :>, @node.connected_at
    assert "expired", @node.solid_confirmation.status
    assert_operator 1.year.ago, :>, @node.solid_confirmation.expiration
    assert @node.should_destroy?

    # not connected and expired -> destroy
    @node.nics.each { |nic| nic.update_attribute(:auth_at, nil) }
    @node = Node.find(@node.id)
    assert_nil @node.connected_at
    assert_operator 1.month.ago, :>, @node.created_at
    assert "expired", @node.solid_confirmation.status
    assert_operator 1.year.ago, :>, @node.solid_confirmation.expiration
    assert @node.should_destroy?

    # not connected and uncofirmed -> destroy
    @node.confirmation.delete
    @node = Node.find(@node.id)
    assert_nil @node.connected_at
    assert_operator 1.month.ago, :>, @node.created_at
    assert "unconfirmed", @node.solid_confirmation.status
    assert_operator 1.month.ago, :>, @node.solid_confirmation.expiration
    assert @node.should_destroy?

    # last connection and uncofirmed -> destroy
    @node.nics.each { |nic| nic.update_attribute(:auth_at, 2.years.ago) }
    @node = Node.find(@node.id)
    assert_operator 1.year.ago, :>, @node.connected_at
    assert "unconfirmed", @node.solid_confirmation.status
    assert_operator 1.month.ago, :>, @node.solid_confirmation.expiration
    assert @node.should_destroy?
  end

  test "should not destroy node" do
    assert_operator 1.year.ago, :<, @node.connected_at
    assert "unapproved", @node.solid_confirmation.status
    assert_not @node.should_destroy?
  end

  test "should not destroy permanent node" do
    @node.update_attribute(:created_at, 3.years.ago)
    @node.update_attribute(:permanent, true)
    @node.nics.each { |nic| nic.update_attribute(:auth_at, 2.years.ago) }
    @node.confirmation.update_attribute(:confirmed_at, 2.years.ago)
    @node = Node.find(@node.id)
    assert_operator 1.year.ago, :>, @node.connected_at
    assert "expired", @node.solid_confirmation.status
    assert_operator 1.year.ago, :>, @node.solid_confirmation.expiration
    assert @node.permanent?
    assert_not @node.should_destroy?
  end

  test "should not destroy node it unverifiable network" do
    @node.update_attribute(:created_at, 3.years.ago)
    @node.nics.each { |nic| nic.update_attribute(:auth_at, nil) }
    @node.confirmation.update_attribute(:confirmed_at, 2.years.ago)
    @node.nics.first.network.update_attribute(:unverifiable, true)
    @node = Node.find(@node.id)
    assert_nil @node.connected_at
    assert_operator 1.month.ago, :>, @node.created_at
    assert "expired", @node.solid_confirmation.status
    assert_operator 1.year.ago, :>, @node.solid_confirmation.expiration
    assert @node.nics.first.network.unverifiable?
    assert_not @node.should_destroy?
  end

  test "should disable node" do
    @node.update_attribute(:created_at, 3.years.ago)

    # expired -> disable
    @node.confirmation.update_attribute(:confirmed_at, 2.years.ago)
    @node = Node.find(@node.id)
    assert "expired", @node.solid_confirmation.status
    assert_operator 1.year.ago, :>, @node.solid_confirmation.expiration
    assert @node.should_disable?

    # uncofirmed -> disable
    @node.confirmation.delete
    @node = Node.find(@node.id)
    assert "unconfirmed", @node.solid_confirmation.status
    assert_operator 1.year.ago, :>, @node.solid_confirmation.expiration
    assert @node.should_disable?
  end

  test "should not disable node" do
    assert "unapproved", @node.solid_confirmation.status
    assert_not @node.should_disable?
  end

  test "should not disable permanent node" do
    @node.update_attribute(:created_at, 3.years.ago)
    @node.update_attribute(:permanent, true)
    @node.confirmation.update_attribute(:confirmed_at, 2.years.ago)
    @node = Node.find(@node.id)
    assert "expired", @node.solid_confirmation.status
    assert_operator 1.year.ago, :>, @node.solid_confirmation.expiration
    assert @node.permanent?
    assert_not @node.should_disable?
  end

  # rubocop: enable Rails/SkipsModelValidations
end
