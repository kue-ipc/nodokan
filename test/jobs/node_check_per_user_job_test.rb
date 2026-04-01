require "test_helper"

class NodeCheckPerUserJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @user = users(:user) # has a node only
    @node = nodes(:node) # recently connected and approved
  end

  test "node check for staff" do
    perform_enqueued_jobs do
      NodeCheckPerUserJob.perform_later(users(:staff))
    end
  end

  test "check approved node" do
    perform_enqueued_jobs do
      NodeCheckPerUserJob.perform_later(@user)
    end
  end

  test "check node that has recently expired" do
    @node.confirmation.update!(confirmed_at: (1.year + 2.months).ago)
    @node.reload
    assert_equal :expired, @node.confirmation.status

    assert_enqueued_email_with NoticeNodesMailer, :expired, params: {user: @user, nodes: [@node]} do
      NodeCheckPerUserJob.perform_now(@user)
    end
  end

  test "should disable node that expired a long time ago" do
    @node.confirmation.update!(confirmed_at: (2.years + 2.months).ago)
    @node.reload
    assert_equal :expired, @node.confirmation.status
    assert_operator @node.confirmation.expiration, :<, 1.year.ago
    assert_operator @node.connected_at, :>, 1.year.ago
    assert @node.should_disable?

    assert_enqueued_email_with NoticeNodesMailer, :expired, params: {user: @user, nodes: [@node]} do
      NodeCheckPerUserJob.perform_now(@user)
    end
    assert_not @node.reload.disabled?

    Settings.config.stub(:auto_disable_node, true) do
      assert_enqueued_email_with NoticeNodesMailer, :disable_soon, params: {user: @user, nodes: [@node]} do
        NodeCheckPerUserJob.perform_now(@user)
      end
      assert_not @node.reload.disabled?

      @node.update!(notice: :disable_soon, noticed_at: Time.current, execution_at: Time.current)
      assert_enqueued_email_with NoticeNodesMailer, :disabled, params: {user: @user, nodes: [@node]} do
        NodeCheckPerUserJob.perform_now(@user)
      end
      assert @node.reload.disabled?
    end
  end

  test "should destroy node that expired and connected a long time ago" do
    @node.confirmation.update!(confirmed_at: (2.years + 2.months).ago)
    @node.nics.first.update!(auth_at: (1.year + 2.months).ago)
    @node.reload
    assert_equal :expired, @node.confirmation.status
    assert_operator @node.confirmation.expiration, :<, 1.year.ago
    assert_operator @node.connected_at, :<, 1.year.ago
    assert @node.should_disable?
    assert @node.should_destroy?

    assert_enqueued_email_with NoticeNodesMailer, :expired, params: {user: @user, nodes: [@node]} do
      NodeCheckPerUserJob.perform_now(@user)
    end
    assert_not @node.reload.disabled?

    Settings.config.stub(:auto_disable_node, true) do
      assert_enqueued_email_with NoticeNodesMailer, :disable_soon, params: {user: @user, nodes: [@node]} do
        NodeCheckPerUserJob.perform_now(@user)
      end
      assert_not @node.reload.disabled?

      @node.update!(notice: :disable_soon, noticed_at: Time.current, execution_at: Time.current)
      assert_enqueued_email_with NoticeNodesMailer, :disabled, params: {user: @user, nodes: [@node]} do
        NodeCheckPerUserJob.perform_now(@user)
      end
      assert @node.reload.disabled?
    end
    @node.update!(disabled: false, notice: nil, noticed_at: nil, execution_at: nil)

    Settings.config.stub(:auto_destroy_node, true) do
      assert_enqueued_email_with NoticeNodesMailer, :destroy_soon, params: {user: @user, nodes: [@node]} do
        NodeCheckPerUserJob.perform_now(@user)
      end

      @node.update!(notice: :destroy_soon, noticed_at: Time.current, execution_at: Time.current)
      assert_difference("Bulk.count") do
        assert_enqueued_email_with NoticeNodesMailer, :destroyed, params: {user: @user, nodes: [@node]} do
          NodeCheckPerUserJob.perform_now(@user)
        end
      end
    end
  end
end
