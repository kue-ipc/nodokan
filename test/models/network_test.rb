require "test_helper"

class NetworkTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @network = networks(:client)
  end

  test "enable network" do
    # enablde -> enabled
    assert @network.enabled?
    assert_enqueued_with(job: KeaSubnet4AddJob) do
      assert_enqueued_with(job: KeaSubnet6AddJob) do
        assert @network.enable!
      end
    end
    @network.reload
    assert @network.enabled?

    # disabled -> enabled
    @network = networks(:disabled)
    assert_not @network.enabled?
    assert_enqueued_with(job: KeaSubnet4AddJob) do
      assert_enqueued_with(job: KeaSubnet6AddJob) do
        assert @network.enable!
      end
    end
    @network.reload
    assert @network.enabled?
  end

  test "disbale network" do
    # enabled -> disabled
    assert @network.enabled?
    assert_enqueued_with(job: KeaSubnet4DelJob) do
      assert_enqueued_with(job: KeaSubnet6DelJob) do
        assert @network.disable!
      end
    end
    @network.reload
    assert @network.disabled?

    # disabled -> disabled
    @network = networks(:disabled)
    assert_not @network.enabled?
    assert_enqueued_with(job: KeaSubnet4DelJob) do
      assert_enqueued_with(job: KeaSubnet6DelJob) do
        assert @network.disable!
      end
    end
    @network.reload
    assert @network.disabled?
  end

  test "should not disable all nework" do
    @network = networks(:all)
    assert @network.enabled?
    assert_no_enqueued_jobs do
      assert_not @network.disable!
    end
    assert_equal ["無効は全体ネットワークに設定できません。"], @network.errors.to_a
    @network.reload
    assert @network.enabled?
  end
end
