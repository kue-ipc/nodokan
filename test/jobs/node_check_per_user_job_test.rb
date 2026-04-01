require "test_helper"

class NodeCheckPerUserJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @user = users(:staff)
    @node = nodes(:node)
  end

  test "node check for staff" do
    perform_enqueued_jobs do
      NodeCheckPerUserJob.perform_later(users(:staff))
    end
  end

  test "no node" do
    perform_enqueued_jobs do
      NodeCheckPerUserJob.perform_later(users(:less))
    end
  end
end
