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

  test "do not notice node that approved" do
    assert_equal :approved, @node.confirmation_status

    assert_no_enqueued_emails do
      NodeCheckPerUserJob.perform_now(@user)
    end
  end

  test "do not notice node that unapproved" do
    @node.confirmation.update!(approved: false, confirmed_at: 1.week.ago)
    @node.reload
    assert_equal :unapproved, @node.confirmation_status

    assert_no_enqueued_emails do
      NodeCheckPerUserJob.perform_now(@user)
    end
  end


  test "notic node that is about to expire" do
    @node.confirmation.update!(confirmed_at: (1.year + 1.month - 1.week).ago)
    @node.reload
    assert_equal :expire_soon, @node.confirmation_status

    assert_enqueued_email_with NoticeNodesMailer, :expire_soon, params: {user: @user, nodes: [@node]} do
      NodeCheckPerUserJob.perform_now(@user)
    end

    # second notice should not be sent
    @node.update!(notice: :expire_soon, noticed_at: Time.current)
    assert_no_enqueued_emails do
      NodeCheckPerUserJob.perform_now(@user)
    end
  end

  test "notic node that has recently expired" do
    @node.confirmation.update!(confirmed_at: (1.year + 2.months).ago)
    @node.reload
    assert_equal :expired, @node.confirmation_status
    assert_operator @node.confirmation.expiration, :>, 1.year.ago

    assert_enqueued_email_with NoticeNodesMailer, :expired, params: {user: @user, nodes: [@node]} do
      NodeCheckPerUserJob.perform_now(@user)
    end

    # second notice should not be sent
    @node.update!(notice: :expired, noticed_at: Time.current)
    assert_no_enqueued_emails do
      NodeCheckPerUserJob.perform_now(@user)
    end
  end

  test "notic node that has disabled" do
    @node.update!(disabled: true)
    @node.reload
    assert @node.disabled?

    assert_enqueued_email_with NoticeNodesMailer, :disabled, params: {user: @user, nodes: [@node]} do
      NodeCheckPerUserJob.perform_now(@user)
    end

    # second notice should not be sent
    @node.update!(notice: :disabled, noticed_at: Time.current)
    assert_no_enqueued_emails do
      NodeCheckPerUserJob.perform_now(@user)
    end
  end


  test "should disable node that expired a long time ago" do
    @node.confirmation.update!(confirmed_at: (2.years + 2.months).ago)
    @node.reload
    assert_operator @node.connected_at, :>, 1.year.ago
    assert_operator @node.confirmation.expiration, :<, 1.year.ago
    assert_equal :expired, @node.confirmation_status
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
      assert_in_delta 1.month.since, @node.reload.execution_at, 1.day

      # second notice should not be sent before exectuion time
      @node.update!(notice: :disable_soon, noticed_at: (1.month - 1.day).ago)
      assert_no_enqueued_emails do
        NodeCheckPerUserJob.perform_now(@user)
      end

      # final notice should be sent just before exectuion time
      @node.update!(execution_at: (1.week - 1.day).since)
      assert_enqueued_email_with NoticeNodesMailer, :disable_soon, params: {user: @user, nodes: [@node]} do
        NodeCheckPerUserJob.perform_now(@user)
      end

      # disable node afuter exectuion time
      @node.update!(execution_at: 1.day.ago)
      assert_enqueued_email_with NoticeNodesMailer, :disabled, params: {user: @user, nodes: [@node]} do
        NodeCheckPerUserJob.perform_now(@user)
      end
      assert @node.reload.disabled?
    end
  end

  test "should destroy node that expired and connected a long time ago" do
    @node.nics.update!(auth_at: (1.year + 2.months).ago)
    @node.confirmation.update!(confirmed_at: (2.years + 2.months).ago)
    @node.reload
    assert_operator @node.connected_at, :<, 1.year.ago
    assert_operator @node.confirmation.expiration, :<, 1.year.ago
    assert_equal :expired, @node.confirmation_status
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
      assert_in_delta 1.month.since, @node.reload.execution_at, 1.day

      @node.update!(notice: :disable_soon, noticed_at: 1.day.ago, execution_at: 1.day.ago)
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
      assert_in_delta 1.month.since, @node.reload.execution_at, 1.day

      # second notice should not be sent before exectuion time
      @node.update!(notice: :destroy_soon, noticed_at: (1.month - 1.day).ago)
      assert_no_enqueued_emails do
        NodeCheckPerUserJob.perform_now(@user)
      end

      # final notice should be sent just before exectuion time
      @node.update!(execution_at: (1.week - 1.day).since)
      assert_enqueued_email_with NoticeNodesMailer, :destroy_soon, params: {user: @user, nodes: [@node]} do
        NodeCheckPerUserJob.perform_now(@user)
      end

      # destroy node afuter exectuion time
      @node.update!(execution_at: 1.day.ago)
      assert_difference("Bulk.count") do
        assert_enqueued_emails 1 do
          NodeCheckPerUserJob.perform_now(@user)
        end
      end

      mail = enqueued_jobs.last
      assert_equal "NoticeNodesMailer", mail[:args][0]
      assert_equal "destroyed", mail[:args][1]
      assert_equal "gid://nodokan/User/#{@user.id}", mail[:args][3]["params"]["user"]["_aj_globalid"]
      assert_equal "gid://nodokan/Bulk/#{Bulk.last.id}", mail[:args][3]["params"]["bulk"]["_aj_globalid"]
      assert_equal [{**@node.as_json, "_aj_symbol_keys"=>[]}], mail[:args][3]["params"]["nodes"]
    end
  end

  test "reset execution time for disbale to destroy" do
    @node.nics.update!(auth_at: (1.year + 2.months).ago)
    @node.confirmation.update!(confirmed_at: (2.years + 2.months).ago)
    @node.update!(notice: :disable_soon, noticed_at: 1.day.ago, execution_at: 1.day.since)
    assert @node.should_disable?
    assert @node.should_destroy?

    Settings.config.stub(:auto_disable_node, true) do
      # disable notice should not be sent
      assert_no_enqueued_emails do
        NodeCheckPerUserJob.perform_now(@user)
      end

      Settings.config.stub(:auto_destroy_node, true) do
        # destroy notice should be sent instead of disable notice
        assert_enqueued_email_with NoticeNodesMailer, :destroy_soon, params: {user: @user, nodes: [@node]} do
          NodeCheckPerUserJob.perform_now(@user)
        end
      end
    end
  end
end
