require "test_helper"

class KeaSubnetCheckAllJobTest < ActiveJob::TestCase
  test "check all" do
    perform_enqueued_jobs do
      KeaSubnetCheckAllJob.perform_later
    end
  end
end
