require "test_helper"

class NodeCheckAllJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "node check" do
    assert_enqueued_email_with NoticeNodesMailer, :unowned, params: {nodes: [nodes(:unowned_node)]} do
      assert_enqueued_email_with NoticeNodesMailer, :deleted_owner, params: {nodes: [nodes(:deleted_user_node)]} do
        assert_enqueued_with(job: NodeCheckPerUserJob) do
          # use perform_now for check enqueued jobs
          NodeCheckAllJob.perform_now
        end
      end
    end
  end
end
