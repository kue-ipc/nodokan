require "test_helper"

class KeaReservationCheckAllJobTest < ActiveJob::TestCase
  test "check all" do
    perform_enqueued_jobs do
      KeaReservationCheckAllJob.perform_later
    end
  end
end
