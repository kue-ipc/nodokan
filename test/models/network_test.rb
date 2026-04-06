require "test_helper"

class NetworkTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @network = networks(:client)
  end

  test "enable network" do
    # enablde -> enabled
    assert_predicate @network, :enabled?
    assert_enqueued_with(job: KeaSubnet4AddJob) do
      assert_enqueued_with(job: KeaSubnet6AddJob) do
        assert @network.enable!
      end
    end
    @network.reload

    assert_predicate @network, :enabled?

    # disabled -> enabled
    @network = networks(:disabled)

    assert_predicate @network, :disabled?
    assert_enqueued_with(job: KeaSubnet4AddJob) do
      assert_enqueued_with(job: KeaSubnet6AddJob) do
        assert @network.enable!
      end
    end
    @network.reload

    assert_predicate @network, :enabled?
  end

  test "disable network" do
    # enabled -> disabled
    assert_predicate @network, :enabled?
    assert_enqueued_with(job: KeaSubnet4DelJob) do
      assert_enqueued_with(job: KeaSubnet6DelJob) do
        assert @network.disable!
      end
    end
    @network.reload

    assert_predicate @network, :disabled?

    # disabled -> disabled
    @network = networks(:disabled)

    assert_predicate @network, :disabled?
    assert_enqueued_with(job: KeaSubnet4DelJob) do
      assert_enqueued_with(job: KeaSubnet6DelJob) do
        assert @network.disable!
      end
    end
    @network.reload

    assert_predicate @network, :disabled?
  end

  test "should not disable all nework" do
    @network = networks(:all)
    assert_no_enqueued_jobs do
      assert_not @network.disable!
    end
    assert_equal ["無効は全体ネットワークに設定できません。"], @network.errors.to_a
    @network.reload

    assert_predicate @network, :enabled?
  end
end
